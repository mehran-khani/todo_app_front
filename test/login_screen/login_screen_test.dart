import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/screens/email_verification_screen.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/login_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import '../auth_service/AuthService.mocks.dart';
import '../registration_screen/registration_screen_test.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late AuthenticationCubit authenticationCubit;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
    authenticationCubit = AuthenticationCubit();

    authenticationCubit.authService = mockAuthService;
    authenticationCubit.secureStorageService = mockSecureStorageService;

    navigatorKey = GlobalKey<NavigatorState>();
  });

  tearDown(() {
    authenticationCubit.close();
  });

  group(
    'Login screen tests',
    () {
      // Testing login logic
      testWidgets(
        'Successful login navigates to HomeScreen and shows success message',
        (WidgetTester tester) async {
          final mockUser = UserModel(
            email: 'test10@example.com',
            name: 'User',
            isVerified: true,
          );

          when(mockAuthService.login(any, any)).thenAnswer(
            (_) async {
              return {
                'message': 'Login successful',
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
                home: const LoginScreen(),
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

          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          debugPrint(
              'SnackBar found: ${find.byType(SnackBar).evaluate().isNotEmpty}');
          debugPrint(
              'HomeScreen found: ${find.byType(HomeScreen).evaluate().isNotEmpty}');

          expect(find.byType(SnackBar), findsOneWidget);

          expect(find.text('Login successful'), findsOne);

          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      // Testing the LoginScreen UI and elements
      testWidgets(
        'LoginScreen displays correctly',
        (WidgetTester tester) async {
          // Build our app and trigger a frame.
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (context) => authenticationCubit,
                child: const LoginScreen(),
              ),
            ),
          );

          // Verify the initial state of the screen
          expect(find.text('Login'), findsOneWidget);
          expect(find.byType(TextFormField),
              findsNWidgets(2)); // email and password fields
          expect(find.byType(ElevatedButton), findsOneWidget);
        },
      );

      // Testing how the form reacts to user actions
      testWidgets(
        'Form validation works correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (context) => authenticationCubit,
                child: const LoginScreen(),
              ),
            ),
          );

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text('Please enter your email'), findsOneWidget);
          expect(find.text('Please enter your password'), findsOneWidget);

          await tester.enterText(
              find.byType(TextFormField).at(0), 'test10@example.com');
          await tester.enterText(
              find.byType(TextFormField).at(1), 'password123');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text('Please enter your email'), findsNothing);
          expect(find.text('Please enter your password'), findsNothing);
        },
      );

      testWidgets('Failed login shows error message',
          (WidgetTester tester) async {
        when(mockAuthService.login(any, any))
            .thenThrow(Exception('Login failed'));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => authenticationCubit,
              child: const LoginScreen(),
            ),
          ),
        );

        await tester.enterText(
            find.byType(TextFormField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(find.text('Exception: Login failed'), findsOneWidget);
      });
    },
  );
}
