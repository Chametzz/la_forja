import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/domain/repositories/user_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepository;

  AuthCubit({required this._userRepository}) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _userRepository.authenticate(username, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Usuario o contraseña incorrectos'));
      }
    } catch (e) {
      emit(AuthError('Error de conexión'));
    }
  }
}
