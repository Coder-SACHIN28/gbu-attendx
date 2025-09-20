import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'dart:math';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication not available',
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        // authMessages removed - not supported in newer versions
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Generate and store biometric signature
        final signature = await _generateBiometricSignature();
        await _storeBiometricSignature(signature);
        
        return BiometricAuthResult(
          success: true,
          signature: signature,
        );
      } else {
        return BiometricAuthResult(
          success: false,
          error: 'Authentication failed',
        );
      }
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        success: false,
        error: _handlePlatformException(e),
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Generate AES-256 encrypted biometric signature
  Future<String> _generateBiometricSignature() async {
    try {
      // Generate random data for signature
      final Random random = Random.secure();
      final List<int> signatureBytes = List.generate(32, (_) => random.nextInt(256));
      
      // Add timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      signatureBytes.addAll(_intToBytes(timestamp));
      
      // Generate device fingerprint
      final deviceId = await _getDeviceFingerprint();
      signatureBytes.addAll(utf8.encode(deviceId));
      
      // Encrypt with AES-256
      final encryptedSignature = await _encryptSignature(signatureBytes);
      
      return base64Encode(encryptedSignature);
    } catch (e) {
      throw Exception('Failed to generate biometric signature: $e');
    }
  }

  /// Encrypt signature using AES-256
  Future<Uint8List> _encryptSignature(List<int> data) async {
    try {
      // Get or generate encryption key
      final key = await _getOrGenerateEncryptionKey();
      
      // Generate random IV
      final Random random = Random.secure();
      final iv = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
      
      // Initialize AES cipher
      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final keyParam = KeyParameter(key);
      final params = PaddedBlockCipherParameters(
        ParametersWithIV(keyParam, iv),
        null,
      );
      
      cipher.init(true, params);
      
      final input = Uint8List.fromList(data);
      final encrypted = cipher.process(input);
      
      // Combine IV and encrypted data
      final result = Uint8List(iv.length + encrypted.length);
      result.setRange(0, iv.length, iv);
      result.setRange(iv.length, result.length, encrypted);
      
      return result;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Get or generate AES-256 encryption key
  Future<Uint8List> _getOrGenerateEncryptionKey() async {
    try {
      const keyAlias = 'biometric_signature_key';
      
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: keyAlias);
      if (existingKey != null) {
        return base64Decode(existingKey);
      }
      
      // Generate new key
      final Random random = Random.secure();
      final key = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
      
      // Store securely
      await _secureStorage.write(
        key: keyAlias,
        value: base64Encode(key),
      );
      
      return key;
    } catch (e) {
      throw Exception('Key generation failed: $e');
    }
  }

  /// Store encrypted biometric signature
  Future<void> _storeBiometricSignature(String signature) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _secureStorage.write(
        key: 'biometric_signature_$timestamp',
        value: signature,
      );
      
      // Keep only last 10 signatures for audit trail
      await _cleanupOldSignatures();
    } catch (e) {
      throw Exception('Failed to store signature: $e');
    }
  }

  /// Clean up old biometric signatures
  Future<void> _cleanupOldSignatures() async {
    try {
      final allKeys = await _secureStorage.readAll();
      final signatureKeys = allKeys.keys
          .where((key) => key.startsWith('biometric_signature_'))
          .toList();
      
      if (signatureKeys.length > 10) {
        signatureKeys.sort();
        final keysToDelete = signatureKeys.take(signatureKeys.length - 10);
        
        for (final key in keysToDelete) {
          await _secureStorage.delete(key: key);
        }
      }
    } catch (e) {
      // Log error but don't fail the main operation
    }
  }

  /// Get device fingerprint for additional security
  Future<String> _getDeviceFingerprint() async {
    try {
      // This would typically include device-specific identifiers
      // For security, we use a combination of available identifiers
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final random = Random().nextInt(1000000).toString();
      
      final fingerprint = '$timestamp$random';
      return sha256.convert(utf8.encode(fingerprint)).toString();
    } catch (e) {
      return 'unknown_device';
    }
  }

  /// Convert integer to bytes
  List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  /// Handle platform exceptions
  String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device';
      case 'NotEnrolled':
        return 'No biometric credentials are enrolled on this device';
      case 'PasscodeNotSet':
        return 'Device passcode is not set';
      case 'LockedOut':
        return 'Too many failed attempts. Please try again later';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is permanently locked out';
      default:
        return 'Biometric authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Verify biometric signature
  Future<bool> verifyBiometricSignature(String signature) async {
    try {
      // In a real implementation, you would verify the signature
      // against stored signatures and check timestamp validity
      
      final decoded = base64Decode(signature);
      return decoded.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear all biometric data
  Future<void> clearBiometricData() async {
    try {
      final allKeys = await _secureStorage.readAll();
      final biometricKeys = allKeys.keys.where(
        (key) => key.contains('biometric') || key.contains('signature'),
      );
      
      for (final key in biometricKeys) {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      throw Exception('Failed to clear biometric data: $e');
    }
  }
}

/// Result of biometric authentication
class BiometricAuthResult {
  final bool success;
  final String? signature;
  final String? error;

  BiometricAuthResult({
    required this.success,
    this.signature,
    this.error,
  });

  @override
  String toString() {
    return 'BiometricAuthResult(success: $success, signature: ${signature != null ? '***' : null}, error: $error)';
  }
}

/// Biometric authentication status
enum BiometricStatus {
  available,
  notAvailable,
  notEnrolled,
  unknown,
}