import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:math';

class FaceRecognitionService {
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  late final FaceDetector _faceDetector;
  bool _isInitialized = false;

  /// Initialize face detection
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: false,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      );

      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize face detection: $e');
    }
  }

  /// Detect faces in camera image
  Future<FaceRecognitionResult> detectFaces(CameraImage cameraImage) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImageToInputImage(cameraImage);
      if (inputImage == null) {
        return FaceRecognitionResult(
          success: false,
          error: 'Failed to convert camera image',
        );
      }

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return FaceRecognitionResult(
          success: false,
          error: 'No faces detected',
        );
      }

      // Perform liveness detection
      final livenessResult = await _performLivenessDetection(faces.first, cameraImage);
      
      if (!livenessResult.isLive) {
        return FaceRecognitionResult(
          success: false,
          error: 'Liveness detection failed: ${livenessResult.reason}',
        );
      }

      return FaceRecognitionResult(
        success: true,
        faceCount: faces.length,
        confidence: livenessResult.confidence,
        livenessScore: livenessResult.score,
      );
    } catch (e) {
      return FaceRecognitionResult(
        success: false,
        error: 'Face detection failed: $e',
      );
    }
  }

  /// Perform liveness detection to prevent spoofing
  Future<LivenessResult> _performLivenessDetection(Face face, CameraImage cameraImage) async {
    try {
      final checks = <String, double>{};
      double totalScore = 0.0;
      int passedChecks = 0;

      // 1. Head pose check - ensure face is looking straight
      final headPose = _checkHeadPose(face);
      checks['headPose'] = headPose;
      if (headPose > 0.7) passedChecks++;
      totalScore += headPose;

      // 2. Eye openness check
      final eyeOpen = _checkEyeOpenness(face);
      checks['eyeOpen'] = eyeOpen;
      if (eyeOpen > 0.6) passedChecks++;
      totalScore += eyeOpen;

      // 3. Smile detection for natural expression
      final smile = _checkSmileNaturalness(face);
      checks['smile'] = smile;
      if (smile > 0.3) passedChecks++;
      totalScore += smile;

      // 4. Face size check - ensure face is at appropriate distance
      final faceSize = _checkFaceSize(face, cameraImage);
      checks['faceSize'] = faceSize;
      if (faceSize > 0.5) passedChecks++;
      totalScore += faceSize;

      // 5. Brightness and contrast check
      final imageQuality = await _checkImageQuality(cameraImage);
      checks['imageQuality'] = imageQuality;
      if (imageQuality > 0.6) passedChecks++;
      totalScore += imageQuality;

      final averageScore = totalScore / checks.length;
      final isLive = passedChecks >= 3 && averageScore > 0.6;

      return LivenessResult(
        isLive: isLive,
        score: averageScore,
        confidence: _calculateConfidence(passedChecks, checks.length),
        reason: isLive ? 'Live face detected' : _generateFailureReason(checks),
        checks: checks,
      );
    } catch (e) {
      return LivenessResult(
        isLive: false,
        score: 0.0,
        confidence: 0.0,
        reason: 'Liveness detection error: $e',
        checks: {},
      );
    }
  }

  /// Check head pose for frontal face
  double _checkHeadPose(Face face) {
    try {
      final rotY = face.headEulerAngleY ?? 0.0;
      final rotZ = face.headEulerAngleZ ?? 0.0;

      // Check if face is roughly frontal (within ±15 degrees)
      final yawScore = 1.0 - (rotY.abs() / 15.0).clamp(0.0, 1.0);
      final rollScore = 1.0 - (rotZ.abs() / 15.0).clamp(0.0, 1.0);

      return (yawScore + rollScore) / 2.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if eyes are open
  double _checkEyeOpenness(Face face) {
    try {
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

      // Both eyes should be reasonably open
      return (leftEyeOpen + rightEyeOpen) / 2.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Check smile naturalness
  double _checkSmileNaturalness(Face face) {
    try {
      final smilingProb = face.smilingProbability ?? 0.5;
      
      // Natural expression range (not too serious, not too smiley)
      if (smilingProb >= 0.3 && smilingProb <= 0.8) {
        return 1.0;
      } else if (smilingProb >= 0.1 && smilingProb <= 0.9) {
        return 0.7;
      } else {
        return 0.3;
      }
    } catch (e) {
      return 0.5;
    }
  }

  /// Check if face size is appropriate
  double _checkFaceSize(Face face, CameraImage cameraImage) {
    try {
      final boundingBox = face.boundingBox;
      final imageArea = cameraImage.width * cameraImage.height;
      final faceArea = boundingBox.width * boundingBox.height;
      final faceRatio = faceArea / imageArea;

      // Face should occupy 10-40% of image
      if (faceRatio >= 0.1 && faceRatio <= 0.4) {
        return 1.0;
      } else if (faceRatio >= 0.05 && faceRatio <= 0.6) {
        return 0.7;
      } else {
        return 0.3;
      }
    } catch (e) {
      return 0.0;
    }
  }

  /// Check image quality (brightness and contrast)
  Future<double> _checkImageQuality(CameraImage cameraImage) async {
    try {
      // Convert camera image to grayscale for analysis
      final grayscale = await _convertToGrayscale(cameraImage);
      
      // Calculate brightness and contrast
      final brightness = _calculateBrightness(grayscale);
      final contrast = _calculateContrast(grayscale);

      // Score based on optimal ranges
      final brightnessScore = _scoreBrightness(brightness);
      final contrastScore = _scoreContrast(contrast);

      return (brightnessScore + contrastScore) / 2.0;
    } catch (e) {
      return 0.5; // Neutral score if analysis fails
    }
  }

  /// Convert CameraImage to InputImage
  InputImage? _convertCameraImageToInputImage(CameraImage cameraImage) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat = InputImageFormat.yuv420;

      final planeData = cameraImage.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final InputImageData inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        inputImageData: inputImageData,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert camera image to grayscale for analysis
  Future<Uint8List> _convertToGrayscale(CameraImage cameraImage) async {
    try {
      // Extract Y channel from YUV420 format (grayscale information)
      return cameraImage.planes[0].bytes;
    } catch (e) {
      // Fallback: create dummy grayscale data
      final size = cameraImage.width * cameraImage.height;
      return Uint8List.fromList(List.filled(size, 128));
    }
  }

  /// Calculate brightness of grayscale image
  double _calculateBrightness(Uint8List grayscale) {
    if (grayscale.isEmpty) return 0.5;

    final sum = grayscale.fold<int>(0, (sum, pixel) => sum + pixel);
    return sum / (grayscale.length * 255.0);
  }

  /// Calculate contrast of grayscale image
  double _calculateContrast(Uint8List grayscale) {
    if (grayscale.isEmpty) return 0.5;

    final mean = _calculateBrightness(grayscale) * 255.0;
    final variance = grayscale
        .map((pixel) => pow(pixel - mean, 2))
        .fold<double>(0.0, (sum, value) => sum + value) / grayscale.length;

    final standardDeviation = sqrt(variance);
    return (standardDeviation / 255.0).clamp(0.0, 1.0);
  }

  /// Score brightness (optimal range: 0.3 - 0.7)
  double _scoreBrightness(double brightness) {
    if (brightness >= 0.3 && brightness <= 0.7) {
      return 1.0;
    } else if (brightness >= 0.2 && brightness <= 0.8) {
      return 0.7;
    } else {
      return 0.3;
    }
  }

  /// Score contrast (optimal range: 0.2 - 0.8)
  double _scoreContrast(double contrast) {
    if (contrast >= 0.2 && contrast <= 0.8) {
      return 1.0;
    } else if (contrast >= 0.1 && contrast <= 0.9) {
      return 0.7;
    } else {
      return 0.3;
    }
  }

  /// Calculate confidence based on passed checks
  double _calculateConfidence(int passedChecks, int totalChecks) {
    return passedChecks / totalChecks;
  }

  /// Generate failure reason based on failed checks
  String _generateFailureReason(Map<String, double> checks) {
    final failedChecks = checks.entries
        .where((entry) => entry.value < 0.5)
        .map((entry) => entry.key)
        .toList();

    if (failedChecks.isEmpty) {
      return 'Overall score too low';
    }

    return 'Failed checks: ${failedChecks.join(', ')}';
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
}

/// Result of face recognition
class FaceRecognitionResult {
  final bool success;
  final int faceCount;
  final double confidence;
  final double livenessScore;
  final String? error;

  FaceRecognitionResult({
    required this.success,
    this.faceCount = 0,
    this.confidence = 0.0,
    this.livenessScore = 0.0,
    this.error,
  });

  @override
  String toString() {
    return 'FaceRecognitionResult(success: $success, faceCount: $faceCount, confidence: $confidence, livenessScore: $livenessScore, error: $error)';
  }
}

/// Result of liveness detection
class LivenessResult {
  final bool isLive;
  final double score;
  final double confidence;
  final String reason;
  final Map<String, double> checks;

  LivenessResult({
    required this.isLive,
    required this.score,
    required this.confidence,
    required this.reason,
    required this.checks,
  });

  @override
  String toString() {
    return 'LivenessResult(isLive: $isLive, score: $score, confidence: $confidence, reason: $reason)';
  }
}