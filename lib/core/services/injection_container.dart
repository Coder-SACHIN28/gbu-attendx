import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/student/presentation/bloc/student_bloc.dart';
import '../../features/teacher/presentation/bloc/teacher_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Initialize all dependencies here
  // For now, using placeholder implementations
  
  // Repositories
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  
  // Use cases
  // getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  
  // Blocs
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(() => StudentBloc());
  sl.registerFactory(() => TeacherBloc());
  
  print('✅ Dependencies initialized successfully');
}