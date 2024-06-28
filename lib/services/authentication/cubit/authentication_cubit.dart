import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthService authService = AuthService();

  AuthenticationCubit() : super(AuthenticationInitial());

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    emit(Loading());

    try {
      final response = await authService.register(
        email,
        password,
        confirmPassword,
        name,
      );
      emit(Success(response['message']));
    } catch (e) {
      emit(Failure('Failed to register: $e'));
    }
  }
}
