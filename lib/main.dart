import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/attendance_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

// Global notification instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize notifications
    await NotificationService.initialize();
    
    // Request permissions
    await _requestPermissions();
    
    print('✅ App initialization successful');
  } catch (e) {
    print('❌ App initialization failed: $e');
  }
  
  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  // Request location permission
  await Permission.location.request();
  await Permission.locationWhenInUse.request();
  
  // Request camera permission
  await Permission.camera.request();
  
  // Request notification permission
  await Permission.notification.request();
  
  // Request storage permission
  await Permission.storage.request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AttendanceProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'GBU AttendX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/student-dashboard': (context) => StudentDashboard(),
          '/teacher-dashboard': (context) => TeacherDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return FutureBuilder(
            future: _getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return SplashScreen();
              }
              
              final role = roleSnapshot.data as String?;
              if (role == 'teacher') {
                return TeacherDashboard();
              } else {
                return StudentDashboard();
              }
            },
          );
        }
        
        return LoginScreen();
      },
    );
  }
  
  Future<String> _getUserRole(String uid) async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData(uid);
      return userData?['role'] ?? 'student';
    } catch (e) {
      return 'student';
    }
  }
}
