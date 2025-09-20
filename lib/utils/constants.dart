class AppConstants {
  // Campus coordinates (GBU, Greater Noida)
  static const double campusLatitude = 28.4504;
  static const double campusLongitude = 77.4850;
  static const double allowedRadius = 500.0; // in meters
  
  // App configuration
  static const String appName = 'GBU AttendX';
  static const String appVersion = '1.0.0';
  
  // Firebase collection names
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';
  static const String classesCollection = 'classes';
  static const String codesCollection = 'verification_codes';
}
