import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/student/presentation/screens/student_dashboard_screen.dart';
import '../features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import '../features/shared/presentation/screens/attendance_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String studentDashboard = '/student-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String attendance = '/attendance';
  
  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );
      case studentDashboard:
        return MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(),
        );
      case teacherDashboard:
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboardScreen(),
        );
      case attendance:
        return MaterialPageRoute(
          builder: (_) => const AttendanceScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}