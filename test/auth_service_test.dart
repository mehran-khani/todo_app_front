import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import 'registration_screen_test.mocks.dart';

class MockSecureStorageService implements SecureStorageService {
  Map<String, String> storage = {};

  @override
  Future<void> writeToken(String key, String value) async {
    storage[key] = value;
  }

  @override
  Future<String?> readToken(String key) async {
    return storage[key];
  }

  @override
  Future<void> deleteAllTokens() async {
    storage.clear();
  }

  @override
  Future<void> deleteToken(String key) async {
    storage.remove(key);
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late AuthenticationCubit authenticationCubit;

  setUpAll(() async {
    // Load .env file
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
    authenticationCubit = AuthenticationCubit()
      ..authService = mockAuthService
      ..secureStorageService = mockSecureStorageService;
  });

  group('AuthService Tests', () {
    final AuthService authService = AuthService();

    test('Register Test', () async {
      String email =
          'user_${DateTime.now().millisecondsSinceEpoch}@example.com';
      const String password = 'password123';
      const String confirmPassword = 'password123';
      const String name = 'User';
      try {
        final response = await authService.register(
          email,
          password,
          confirmPassword,
          name,
        );

        // Assertions
        expect(response['message'],
            'User registered successfully. Please check your email for verification link.');
      } on DioException catch (e) {
        fail('Failed to register: ${e.response?.data ?? e.message}');
      } catch (e) {
        fail('Failed to register: $e');
      }
    });

    test('Login Test', () async {
      const String email = 'change it to a valid registered email adress';
      const String password = 'password123';

      final response = await authService.login(email, password);

      // Assertions
      expect(response['message'], 'Login successful');
      expect(response['access'], isNotEmpty);
      expect(response['refresh'], isNotEmpty);
    });

    test('Refresh Token Test', () async {
      final authService = AuthService();

      // First, authenticate to get a real refresh token
      const String email = 'change it to a valid registered email adress';
      const String password = 'password123';

      try {
        final loginResponse = await authService.login(email, password);

        final String refreshToken = loginResponse['refresh'];

        // Now, use the obtained refresh token to test the refreshToken method
        final response = await authService.refreshToken(refreshToken);
        // Assertions
        expect(response, isNotEmpty);
        expect(response['access'], isNotNull);
        expect(response['refresh'], isNotNull);
      } on DioException catch (e) {
        fail('Failed to refresh token: ${e.response?.data ?? e.message}');
      } catch (e) {
        fail('Failed to refresh token: $e');
      }
    });
  });

  group('AuthenticationCubit Tests', () {
    test('Cubit Register Test', () async {
      const String email = 'test@gmail.com';
      const String password = 'password123';
      const String confirmPassword = 'password123';
      const String name = 'User';

      when(mockAuthService.register(email, password, confirmPassword, name))
          .thenAnswer((_) async => {
                'access': 'fake_access_token',
                'refresh': 'fake_refresh_token',
                'message': 'User registered successfully'
              });

      await authenticationCubit.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
      );

      expect(
          authenticationCubit.state,
          isA<Success>().having((state) => state.message, 'message',
              'User registered successfully'));
    });

    test('Cubit Login Test', () async {
      const String email = 'test@gmail.com';
      const String password = 'password123';

      when(mockAuthService.login(email, password)).thenAnswer((_) async => {
            'access': 'fake_access_token',
            'refresh': 'fake_refresh_token',
            'message': 'Login successful'
          });

      await authenticationCubit.login(email: email, password: password);

      expect(
          authenticationCubit.state,
          isA<Success>()
              .having((state) => state.message, 'message', 'Login successful'));
    });

    test('Cubit Logout Test', () async {
      mockSecureStorageService.deleteAllTokens();

      await authenticationCubit.logout();

      expect(authenticationCubit.state, isA<LoggedOut>());
    });
  });

  group('validating tokens and checking auth status', () {
    final AuthService authService = AuthService();

    group('isAccessTokenValid', () {
      test('Valid access token', () async {
        const String email = 'change it to a valid registered email adress';
        const String password = 'password123';

        // Generate or load a real valid access token for testing
        final response = await authService.login(email, password);
        print('Login Response: $response');

        expect(response, contains('access'));

        String accessToken = response['access'];
        print('Access Token: $accessToken');

        // Write token to storage
        await mockSecureStorageService.writeToken('accessToken', accessToken);

        // Check if token is valid
        final isValid = await authenticationCubit.isAccessTokenValid();
        print('Is Valid Token: $isValid');

        expect(isValid, true);
      });

      test('Invalid access token', () async {
        const String accessToken = 'invalid_access_token';
        mockSecureStorageService.writeToken('accessToken', accessToken);
        mockSecureStorageService.readToken('accessToken');

        final isValid = await authenticationCubit.isAccessTokenValid();

        expect(isValid, false);
      });
    });

    group('checkAuthStatus', () {
      test('Valid tokens', () async {
        const String email = 'change it to a valid registered email adress';
        const String password = 'password123';

        final response = await authService.login(email, password);

        String accessToken = response['access'];
        String refreshToken = response['refresh'];

        await mockSecureStorageService.writeToken('accessToken', accessToken);
        await mockSecureStorageService.writeToken('refreshToken', refreshToken);

        await mockSecureStorageService.readToken('accessToken');
        await mockSecureStorageService.readToken('refreshToken');

        await authenticationCubit.checkAuthStatus();

        expect(authenticationCubit.state, const Success('Tokens are valid'));
      });

      test('Both tokens missing or invalid', () async {
        mockSecureStorageService.writeToken(
            'accessToken', 'Invalid access token');
        mockSecureStorageService.writeToken(
            'refreshToken', 'Invalid refresh token');

        mockSecureStorageService.readToken('accessToken');
        mockSecureStorageService.readToken('refreshToken');

        await authenticationCubit.checkAuthStatus();

        expect(authenticationCubit.state, isA<LoggedOut>());
      });
    });
  });
}
