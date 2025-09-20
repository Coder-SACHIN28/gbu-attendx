import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/injection_container.dart' as di;
import '../core/utils/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/student/presentation/bloc/student_bloc.dart';
import '../features/teacher/presentation/bloc/teacher_bloc.dart';
import 'routes.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider<StudentBloc>(
          create: (context) => di.sl<StudentBloc>(),
        ),
        BlocProvider<TeacherBloc>(
          create: (context) => di.sl<TeacherBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'GBU AttendX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
        builder: (context, child) {
          // Set system UI overlay style
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
          );
          return child!;
        },
      ),
    );
  }
}