import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import '../auth_service/AuthService.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthenticationCubit>(),
])
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  writeToken(String key, String value) async {
    _storage[key] = value;
  }

  @override
  readToken(String key) async {
    return _storage[key];
  }

  @override
  deleteAllTokens() async {
    _storage.clear();
  }

  @override
  deleteToken(String key) async {
    _storage.remove(key);
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late AuthenticationCubit authenticationCubit;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load .env file
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    // Mock the MethodChannel for flutter_secure_storage
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
        .setMockMethodCallHandler((call) async {
      if (call.method == 'read') {
        final result =
            await mockSecureStorageService.readToken(call.arguments['key']);
        return Future.value(result);
      }
      if (call.method == 'write') {
        await mockSecureStorageService.writeToken(
            call.arguments['key'], call.arguments['value']);
        return Future<void>.value();
      }
      if (call.method == 'delete') {
        await mockSecureStorageService.deleteToken(call.arguments['key']);
        return Future<void>.value();
      }
      if (call.method == 'deleteAll') {
        await mockSecureStorageService.deleteAllTokens();
        return Future<void>.value();
      }
    });

    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
    authenticationCubit = AuthenticationCubit()
      ..authService = mockAuthService
      ..secureStorageService = mockSecureStorageService;
  });

  group('AuthenticationCubit Tests', () {
    test('Cubit Register Test', () async {
      const String email = 'test@gmail.com';
      const String password = 'password123';
      const String confirmPassword = 'password123';
      const String name = 'User';

      final user = UserModel(
        email: email,
        name: name,
        isVerified: false,
      );

      when(mockAuthService.register(email, password, confirmPassword, name))
          .thenAnswer((_) async => {
                'access': 'fake_access_token',
                'refresh': 'fake_refresh_token',
                'message':
                    'User registered successfully. Please check your email for verification link.',
                'user': user,
              });

      await authenticationCubit.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
      );

      expect(
          authenticationCubit.state,
          isA<Authenticated>()
              .having((state) => state.message, 'message',
                  'User registered successfully. Please check your email for verification link.')
              .having((state) => state.user.email, 'email', email)
              .having((state) => state.user.name, 'name', name)
              .having((state) => state.user.isVerified, 'isActive', false));
    });

    test('Cubit Register Failure Test', () async {
      const String email = 'invalid_email@gmail.com';
      const String password = 'password123';
      const String confirmPassword = 'password123';
      const String name = 'User';

      when(mockAuthService.register(email, password, confirmPassword, name))
          .thenThrow(Exception('Registration failed.'));

      await authenticationCubit.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
      );

      expect(
        authenticationCubit.state,
        isA<Registering>().having((state) => state.error, 'message',
            'Exception: Registration failed.'),
      );
    });

    test('Cubit Login Test', () async {
      const String email = 'test@gmail.com';
      const String password = 'password123';
      const String name = 'User';

      final user = UserModel(
        email: email,
        name: name,
        isVerified: true,
      );

      when(mockAuthService.login(email, password)).thenAnswer((_) async => {
            'access': 'fake_access_token',
            'refresh': 'fake_refresh_token',
            'message': 'Login successful',
            'user': user,
          });

      await authenticationCubit.login(email: email, password: password);

      expect(
        authenticationCubit.state,
        isA<Authenticated>()
            .having((state) => state.message, 'message', 'Login successful')
            .having((state) => state.user.email, 'email', email)
            .having((state) => state.user.name, 'name', 'User')
            .having((state) => state.user.isVerified, 'isActive', true),
      );
    });

    test('Cubit Login Failure Test', () async {
      const String email = 'invalid_email';
      const String password = 'wrong_password';

      when(mockAuthService.login(email, password))
          .thenThrow(Exception('Login failed.'));

      await authenticationCubit.login(email: email, password: password);

      expect(
        authenticationCubit.state,
        isA<LoggedOut>().having(
            (state) => state.error, 'message', 'Exception: Login failed.'),
      );
    });

    test('Cubit Get Current User Test', () async {
      const String accessToken = 'fake_access_token';

      final user = UserModel(
        email: 'test@gmail.com',
        name: 'User',
        isVerified: true,
      );

      await mockSecureStorageService.writeToken('accessToken', accessToken);

      when(mockAuthService.getCurrentUser(accessToken))
          .thenAnswer((_) async => user);

      await authenticationCubit.getCurrentUser();

      expect(
        authenticationCubit.state,
        isA<Authenticated>()
            .having((state) => state.user.email, 'email', 'test@gmail.com')
            .having((state) => state.user.name, 'name', 'User')
            .having((state) => state.user.isVerified, 'isVerified', true),
      );
    });

    test('Cubit Resend Verification Email Test', () async {
      const String email = 'test@gmail.com';

      when(mockAuthService.resendVerificationEmail(email))
          .thenAnswer((_) async => {
                'message': 'Verification email resent successfully.',
              });

      await authenticationCubit.resendVerificationEmail(email: email);

      expect(
        authenticationCubit.state,
        isA<Success>().having((state) => state.message, 'message',
            'Verification email resent successfully.'),
      );
    });

    test('Cubit Logout Test', () async {
      mockSecureStorageService.deleteAllTokens();

      await authenticationCubit.logout();

      expect(authenticationCubit.state, isA<LoggedOut>());
    });
  });

  group('validating tokens and checking auth status', () {
    group('isAccessTokenValid', () {
      test('Invalid access token', () async {
        const String accessToken = 'invalid_access_token';
        mockSecureStorageService.writeToken('accessToken', accessToken);
        mockSecureStorageService.readToken('accessToken');

        final isValid = await authenticationCubit.isAccessTokenValid();

        expect(isValid, false);
      });
    });

    group('checkAuthStatus', () {
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
