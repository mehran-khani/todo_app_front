import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  test('Register Test', () async {
    final authService = AuthService();

    const String email = 'test@gmail.com';
    const String password = 'password123';
    const String confirmPassword = 'password123';
    const String name = 'Mehran';

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
    } catch (e) {
      fail('Failed to register: $e'); // Fail the test if an exception occurs
    }
  });
}
