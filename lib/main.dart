import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/services/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/teacher/presentation/bloc/teacher_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/student/presentation/screens/student_dashboard_screen.dart';

// Global notification instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize local notifications
    await _initializeNotifications();
    
    // Request permissions
    await _requestPermissions();
    
    // Initialize dependency injection
    await di.init();
    
    print('✅ GBU AttendX v${AppConstants.appVersion} initialization successful');
  } catch (e) {
    print('❌ App initialization failed: $e');
  }
  
  runApp(const GBUAttendXApp());
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

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings = 
    AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class GBUAttendXApp extends StatelessWidget {
  const GBUAttendXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<StudentBloc>(
          create: (_) => di.sl<StudentBloc>(),
        ),
        BlocProvider<TeacherBloc>(
          create: (_) => di.sl<TeacherBloc>(),
        ),
      ],
      child: AppWidget(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          // TODO: Implement role-based routing
          // For now, defaulting to student dashboard
          return BlocProvider.value(
            value: context.read<StudentBloc>(),
            child: const StudentDashboardScreen(),
          );
        }
        
        return BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const LoginScreen(),
        );
      },
    );
  }
}
