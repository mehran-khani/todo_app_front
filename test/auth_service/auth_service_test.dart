import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

void main() {
  late AuthService authService;

  setUpAll(() async {
    // Load .env file
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    authService = AuthService();
  });

  group('AuthService Tests', () {
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
        expect(response['user'], isA<UserModel>());
        expect(response['access'], isNotNull);
        expect(response['refresh'], isNotNull);
      } on DioException catch (e) {
        fail('Failed to register: ${e.response?.data ?? e.message}');
      } catch (e) {
        fail('Failed to register: $e');
      }
    });

    test('Login Test', () async {
      const String email = 'write a valid and registered email here';
      const String password = 'User';

      final response = await authService.login(email, password);

      // Assertions
      expect(response['message'], 'Login successful');
      expect(response['user'], isA<UserModel>());
      expect(response['access'], isNotEmpty);
      expect(response['refresh'], isNotEmpty);
    });

    test('login failure', () async {
      const String email = 'invalid_email@gmail.com';
      const String password = 'User';
      try {
        await authService.login(email, password);
        fail('Expected a DioException but did not get one.');
      } on DioException catch (e) {
        // Assertions for DioException
        expect(e.type, DioExceptionType.badResponse);
        expect(e.response?.statusCode, 401);
        expect(
            e.message,
            contains(
                'Client error - the request contains bad syntax or cannot be fulfilled'));
      }
    });

    test('Refresh Token Test', () async {
      final authService = AuthService();

      // First, authenticate to get a real refresh token
      const String email = 'write a valid and registered email here';
      const String password = 'User';

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

    test(
      'Get Current User Test',
      () async {
        const String email = 'write a valid and registered email here';
        const String password = 'User';

        try {
          final loginResponse = await authService.login(email, password);
          final String accessToken = loginResponse['access'];
          final user = await authService.getCurrentUser(accessToken);
          //Assertions
          expect(user, isA<UserModel>());
          expect(user.email, email);
        } on DioException catch (e) {
          fail('Failed to get current user: ${e.response?.data ?? e.message}');
        } catch (e) {
          fail('Failed to get current user: $e');
        }
      },
    );

    test(
      'Resend Verification Email Test',
      () async {
        const String email = 'write a valid and registered email here';

        try {
          final response = await authService.resendVerificationEmail(email);

          expect(response['message'], 'matcherVerification email sent.');
        } on DioException catch (e) {
          fail(
              'Failed to resend verification email: ${e.response?.data ?? e.message}');
        } catch (e) {
          fail('Failed to resend verification email: $e');
        }
      },
    );
  });
}
