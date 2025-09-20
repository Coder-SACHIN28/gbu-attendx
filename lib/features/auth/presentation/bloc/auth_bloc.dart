import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final String userId;
  final String email;
  final String name;

  const AuthenticatedState({
    required this.userId,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [userId, email, name];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthSignUpEvent>(_onSignUp);
  }

  void _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    // TODO: Implement auth status check
    await Future.delayed(const Duration(milliseconds: 500));
    emit(UnauthenticatedState());
  }

  void _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful login
      emit(const AuthenticatedState(
        userId: 'mock_user_id',
        email: 'user@example.com',
        name: 'Mock User',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // TODO: Implement logout logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void _onSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // TODO: Implement sign up logic
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful signup
      emit(const AuthenticatedState(
        userId: 'mock_new_user_id',
        email: 'newuser@example.com',
        name: 'New Mock User',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}