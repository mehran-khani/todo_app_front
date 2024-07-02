import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthService authService = AuthService();
  SecureStorageService secureStorageService = SecureStorageService();

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

      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);
    } catch (e) {
      emit(Failure('Failed to register: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(Loading());

    try {
      final response = await authService.login(email, password);

      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      await secureStorageService.writeToken('accessToken', accessToken);
      await secureStorageService.writeToken('refreshToken', refreshToken);

      emit(Success(response['message']));
    } catch (e) {
      emit(Failure(e.toString()));
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

      emit(Success(response['message']));

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
          // Handle case where 'exp' is missing in token
          print('Token does not contain expiration date.');
          return false;
        }
      } catch (e) {
        // Handle decoding errors
        print('Error decoding token: $e');
        return false;
      }
    } else {
      // Handle case where accessToken is null or empty
      print('Access token is null or empty.');
      return false;
    }
  }

  // Future<bool> isAccessTokenValid() async {
  //   final accessToken = await secureStorageService.readToken('accessToken');
  //   if (accessToken != null) {
  //     try {
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
  //       // Check expiration
  //       if (decodedToken['exp'] != null) {
  //         DateTime expirationDate =
  //             DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
  //         bool isTokenValid = DateTime.now().isBefore(expirationDate);
  //         return isTokenValid;
  //       }
  //     } catch (e) {
  //       print(e.toString());
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  Future<void> checkAuthStatus() async {
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
}
