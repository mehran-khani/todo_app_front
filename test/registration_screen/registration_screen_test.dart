import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/screens/email_verification_screen.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import '../auth_service/AuthService.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
])
class MockSecureStorageService implements SecureStorageService {
  Map<String, String> storage = {};

  @override
  writeToken(String key, String value) async {
    storage[key] = value;
  }

  @override
  readToken(String key) async {
    return storage[key];
  }

  @override
  deleteAllTokens() async {
    storage.clear();
  }

  @override
  deleteToken(String key) async {
    storage.remove(key);
  }
}

void main() {
  group(
    'RegistrationScreen',
    () {
      // initializing the mock and AuthenticationCubit for authentication logic tests
      late MockAuthService mockAuthService;
      late AuthenticationCubit authenticationCubit;
      late MockSecureStorageService mockSecureStorageService;

      setUp(
        () {
          mockAuthService = MockAuthService();
          authenticationCubit = AuthenticationCubit();
          mockSecureStorageService = MockSecureStorageService();

          authenticationCubit.authService = mockAuthService;
          authenticationCubit.secureStorageService = mockSecureStorageService;
        },
      );

      tearDown(
        () {
          authenticationCubit.close();
        },
      );

      // testing registeratoin logic
      testWidgets(
        'Successful registration navigates to EmailVerificationScreen/HomeScreen and shows success message',
        (WidgetTester tester) async {
          final GlobalKey<NavigatorState> navigatorKey =
              GlobalKey<NavigatorState>();

          final mockUser = UserModel(
            email: 'test10@example.com',
            name: 'User',
            isVerified: false,
          );

          when(mockAuthService.register(any, any, any, any)).thenAnswer(
            (_) async {
              return {
                'message':
                    'User registered successfully. Please check your email for verification link.',
                'access': 'your_access_token_value',
                'refresh': 'your_refresh_token_value',
                'user': mockUser,
              };
            },
          );

          final Authenticated state = Authenticated(
              message:
                  'User registered successfully. Please check your email for verification link.',
              user: mockUser,
              isLoading: false);

          await tester.pumpWidget(
            BlocProvider<AuthenticationCubit>(
              create: (_) => authenticationCubit,
              child: MaterialApp(
                navigatorKey: navigatorKey,
                home: const RegistrationScreen(),
                routes: {
                  '/home': (_) => const HomeScreen(),
                  '/register': (context) => const RegistrationScreen(),
                  '/verify-email': (_) => EmailVerificationScreen(
                        email: state.user.email,
                      ),
                },
              ),
            ),
          );

          // Perform the form validation and submission
          await tester.enterText(
              find.byType(TextFormField).at(0), 'test10@example.com');
          await tester.enterText(
              find.byType(TextFormField).at(1), 'password123');
          await tester.enterText(
              find.byType(TextFormField).at(2), 'password123');
          await tester.enterText(find.byType(TextFormField).at(3), 'User');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.byType(SnackBar), findsOneWidget);

          expect(
              find.text(
                  'User registered successfully. Please check your email for verification link.'),
              findsOne);

          if (mockUser.isVerified) {
            expect(find.byType(HomeScreen), findsOneWidget);
          } else {
            expect(find.byType(EmailVerificationScreen), findsOneWidget);
            expect(
              find.text('Please check your email for a verification link.'),
              findsOne,
            );
          }
        },
      );

      // testing the RegistrationScreen UI and elements
      testWidgets(
        'RegistrationScreen displays correctly',
        (WidgetTester tester) async {
          // Build our app and trigger a frame.
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (context) => authenticationCubit,
                child: const RegistrationScreen(),
              ),
            ),
          );
          // Verify the initial state of the screen
          expect(find.text('Register'), findsNWidgets(1));
          expect(find.byType(TextFormField), findsNWidgets(4));
          expect(find.byType(ElevatedButton), findsOneWidget);
        },
      );

      // testing how does our form reacts to users actions
      testWidgets(
        'Form validation works correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (context) => authenticationCubit,
                child: const RegistrationScreen(),
              ),
            ),
          );

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text('Please enter your email'), findsOneWidget);
          expect(find.text('Please enter your password'), findsOneWidget);
          expect(find.text('Please confirm your password'), findsOneWidget);
          expect(find.text('Please enter your name'), findsOneWidget);

          await tester.enterText(
              find.byType(TextFormField).at(0), 'test10@example.com');
          await tester.enterText(
              find.byType(TextFormField).at(1), 'password123');
          await tester.enterText(
              find.byType(TextFormField).at(2), 'password123');
          await tester.enterText(find.byType(TextFormField).at(3), 'User');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text('Please enter your email'), findsNothing);
          expect(find.text('Please enter your password'), findsNothing);
          expect(find.text('Please confirm your password'), findsNothing);
          expect(find.text('Please enter your name'), findsNothing);
        },
      );

      testWidgets('Failed registration shows error message',
          (WidgetTester tester) async {
        when(mockAuthService.register(any, any, any, any))
            .thenThrow(Exception('Registration failed'));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => authenticationCubit,
              child: const RegistrationScreen(),
            ),
          ),
        );

        await tester.enterText(
            find.byType(TextFormField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.enterText(find.byType(TextFormField).at(3), 'User');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(find.text('Exception: Registration failed'), findsOneWidget);
      });
    },
  );
}
