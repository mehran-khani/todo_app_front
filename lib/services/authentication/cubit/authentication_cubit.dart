import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthService authService = AuthService();
  SecureStorageService secureStorageService = SecureStorageService();

  AuthenticationCubit() : super(const LoggedOut(isLoading: false)) {
    init();
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    emit(const Registering(
      isLoading: true,
    ));

    try {
      final response = await authService.register(
        email,
        password,
        confirmPassword,
        name,
      );

      final user = response['user'] as UserModel;
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);

      emit(Authenticated(
        user: user,
        message: response['message'],
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(Registering(isLoading: false, error: e.toString()));
    }
  }

  Future<void> resendVerificationEmail({required String email}) async {
    emit(const Verifying(isLoading: true));
    try {
      final response = await authService.resendVerificationEmail(email);
      log('this is resend email : $response');
      emit(Success(
        message: response['message'],
        isLoading: false,
      ));
    } catch (e) {
      emit(Verifying(
        isLoading: false,
        error: 'Failed to resend verification email: $e',
      ));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const LoggedOut(isLoading: true));

    try {
      final response = await authService.login(email, password);

      final user = response['user'] as UserModel;
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);

      emit(Authenticated(
          user: user,
          message: response['message'],
          isLoading: false,
          error: null));
    } catch (e) {
      log('$e');
      emit(LoggedOut(isLoading: false, error: e.toString()));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final accessToken = await secureStorageService.readToken('accessToken');
      final UserModel user = await authService.getCurrentUser(accessToken!);
      emit(Authenticated(
        user: user,
        message: 'Welcome ${user.name}',
        isLoading: false,
      ));
      return user;
    } catch (e) {
      emit(LoggedOut(
          isLoading: false, error: 'Failed to fetch current user: $e'));
      return null;
    }
  }

  Future<bool> checkUserStatus() async {
    emit(const Verifying(isLoading: true));
    final accessToken = await secureStorageService.readToken('accessToken');

    try {
      final UserModel user = await authService.getCurrentUser(accessToken!);
      if (user.isVerified) {
        emit(Authenticated(
          user: user,
          message: 'User is verified',
          isLoading: false,
        ));
        return true;
      } else {
        emit(const LoggedOut(
          isLoading: false,
          error: 'User is not verified',
        ));
        return false;
      }
    } catch (e) {
      emit(LoggedOut(
        isLoading: false,
        error: 'Failed to check user status: $e',
      ));
      return false;
    }
  }

  Future<bool> refresh() async {
    emit(const Verifying(isLoading: true));

    try {
      final refreshToken = await secureStorageService.readToken('refreshToken');
      final response = await authService.refreshToken(refreshToken!);

      final newAccessToken = response['access'];
      final newRefreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', newAccessToken);
      await secureStorageService.writeToken('refreshToken', newRefreshToken);

      return true; // Refresh successful
    } catch (e) {
      emit(const LoggedOut(isLoading: false));
      return false; // Refresh failed
    }
  }

  Future<void> logout() async {
    await secureStorageService.deleteAllTokens();
    emit(const LoggedOut(isLoading: false));
  }

  Future<bool> isAccessTokenValid() async {
    final accessToken = await secureStorageService.readToken('accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        final decodedToken = JwtDecoder.decode(accessToken);

        // Check expiration
        if (decodedToken['exp'] != null) {
          DateTime expirationDate =
              DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
          bool isTokenValid = DateTime.now().isBefore(expirationDate);
          return isTokenValid;
        } else {
          //TODO: Handle case where 'exp' is missing in token
          return false;
        }
      } catch (e) {
        //TODO: Handle decoding errors
        return false;
      }
    } else {
      //TODO: Handle case where accessToken is null or empty
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const Verifying(isLoading: true));

    try {
      final accessToken = await secureStorageService.readToken('accessToken');
      final refreshToken = await secureStorageService.readToken('refreshToken');

      if (accessToken != null && await isAccessTokenValid()) {
        final user = await getCurrentUser();

        if (user == null) {
          emit(const LoggedOut(isLoading: false));
          return;
        }

        emit(Authenticated(
          user: user,
          message: 'Token is Valid',
          isLoading: false,
        ));
      } else if (await isAccessTokenValid() == false && refreshToken != null) {
        emit(const Verifying(isLoading: true));
        final bool refreshed = await refresh();
        if (refreshed) {
          emit(const Success(
            message: 'Token is refreshed',
            isLoading: false,
          ));
        } else {
          await logout();
          emit(const LoggedOut(isLoading: false));
        }
      } else {
        await logout();
        emit(const LoggedOut(isLoading: false));
      }
    } catch (e) {
      emit(const LoggedOut(isLoading: false));
    }
  }

  Future<void> init() async {
    emit(const Verifying(isLoading: true));
    final user = await getCurrentUser();
    if (user == null) {
      emit(const LoggedOut(isLoading: false));
    } else if (user.isVerified) {
      emit(Authenticated(
        user: user,
        message: 'Welcome ${user.name}',
        isLoading: false,
      ));
    } else if (user.isVerified == false) {
      emit(Authenticated(
        user: user,
        message: 'Welcome ${user.name}, please verifiy your email!',
        isLoading: false,
      ));
    }
  }
}
