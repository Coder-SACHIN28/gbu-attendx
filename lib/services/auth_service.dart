import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    // Placeholder implementation
    return {'role': 'student', 'name': 'Demo User'};
  }
}
