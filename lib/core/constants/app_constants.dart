class AppConstants {
  // App Information
  static const String appName = 'GBU AttendX';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'Smart Attendance Management System';
  
  // University Information
  static const String universityName = 'Gautam Buddha University';
  static const String universityShortName = 'GBU';
  
  // Campus Coordinates (GBU Greater Noida)
  static const double campusLatitude = 28.4504;
  static const double campusLongitude = 77.4850;
  static const double allowedRadius = 500.0; // meters
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';
  static const String classesCollection = 'classes';
  static const String timetableCollection = 'timetable';
  static const String codesCollection = 'verification_codes';
  static const String leaveRequestsCollection = 'leave_requests';
  static const String notificationsCollection = 'notifications';
  
  // Local Storage Keys
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Attendance Configuration
  static const int attendanceTimeWindowMinutes = 15;
  static const int lateArrivalThresholdMinutes = 10;
  static const int codeExpiryMinutes = 5;
  static const int maxAttendanceRetries = 3;
  
  // Biometric Configuration
  static const int biometricTimeoutSeconds = 30;
  static const double biometricConfidenceThreshold = 0.8;
  
  // Network Configuration
  static const String baseUrl = 'https://api.gbu-attendx.com/v1';
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetries = 3;
  static const bool isDebugMode = true;
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String locationErrorMessage = 'Unable to get location. Please enable GPS.';
  static const String biometricErrorMessage = 'Biometric authentication failed.';
  static const String cameraErrorMessage = 'Camera access denied.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  
  // Success Messages
  static const String attendanceMarkedMessage = 'Attendance marked successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String logoutSuccessMessage = 'Logged out successfully!';
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
  
  // Animation Durations (milliseconds)
  static const int shortAnimationDuration = 300;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 1000;
  
  // Image Configuration
  static const int maxImageSizeKB = 500;
  static const int imageCompressionQuality = 85;
  static const int thumbnailSize = 150;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // URLs and Links
  static const String universityWebsite = 'https://www.gbu.ac.in';
  static const String supportEmail = 'support@gbu.ac.in';
  static const String privacyPolicyUrl = 'https://www.gbu.ac.in/privacy';
  static const String termsOfServiceUrl = 'https://www.gbu.ac.in/terms';
}