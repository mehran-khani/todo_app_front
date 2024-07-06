import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthService authService = AuthService();
  SecureStorageService secureStorageService = SecureStorageService();

  AuthenticationCubit() : super(LoggedOut()) {
    init();
  }

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

      final user = response['user'] as UserModel;
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);

      emit(Authenticated(response['message'], user));
    } catch (e) {
      emit(Failure('Failed to register: $e'));
    }
  }

  Future<void> resendVerificationEmail({required String email}) async {
    print('object');

    try {
      emit(Loading());
      final response = await authService.resendVerificationEmail(email);
      print('this is resend email : $response');
      // final user = await getCurrentUser();
      // print(user);
      emit(Success(response['message']));
    } catch (e) {
      emit(Failure('Failed to resend verification email: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(Loading());

    try {
      final response = await authService.login(email, password);

      final user = response['user'] as UserModel;
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);

      emit(Authenticated(response['message'], user));
    } catch (e) {
      emit(Failure(e.toString()));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final accessToken = await secureStorageService.readToken('accessToken');
      final UserModel user = await authService.getCurrentUser(accessToken!);
      emit(Authenticated('Welcome ${user.name}', user));
      return user;
    } catch (e) {
      emit(Failure('Failed to fetch current user: $e'));
      return null;
    }
  }

  Future<bool> checkUserStatus() async {
    emit(Loading());
    final accessToken = await secureStorageService.readToken('accessToken');

    try {
      final UserModel user = await authService.getCurrentUser(accessToken!);
      if (user.isVerified) {
        emit(Authenticated('User is active', user));
        return true;
      } else {
        emit(const Failure('User is not active'));
        return false;
      }
    } catch (e) {
      emit(Failure('Failed to check user status: $e'));
      return false;
    }
  }

  Future<bool> refresh() async {
    emit(Loading());

    try {
      final refreshToken = await secureStorageService.readToken('refreshToken');
      final response = await authService.refreshToken(refreshToken!);

      final newAccessToken = response['access'];
      final newRefreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', newAccessToken);
      await secureStorageService.writeToken('refreshToken', newRefreshToken);

      return true; // Refresh successful
    } catch (e) {
      emit(Failure(e.toString()));
      return false; // Refresh failed
    }
  }

  Future<void> logout() async {
    await secureStorageService.deleteAllTokens();
    emit(LoggedOut());
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
    emit(Loading());

    try {
      final accessToken = await secureStorageService.readToken('accessToken');
      final refreshToken = await secureStorageService.readToken('refreshToken');

      if (accessToken != null && await isAccessTokenValid()) {
        emit(const Success('Tokens are valid'));
      } else if (await isAccessTokenValid() == false && refreshToken != null) {
        final bool refreshed = await refresh();
        if (refreshed) {
          emit(const Success('Token is refreshed'));
        } else {
          await logout();
          emit(LoggedOut());
        }
      } else {
        await logout();
        emit(LoggedOut());
      }
    } catch (e) {
      emit(Failure(e.toString()));
    }
  }

  Future<void> init() async {
    final user = await getCurrentUser();
    if (user == null) {
      emit(LoggedOut());
    } else if (user.isVerified) {
      emit(Authenticated('Welcome ${user.name}', user));
    } else if (user.isVerified == false) {
      emit(Authenticated(
          'Welcome ${user.name}, please verifiy your email!', user));
    }
  }
}
