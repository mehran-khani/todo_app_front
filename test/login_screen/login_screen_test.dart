import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/login_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import '../email_verification_screen/email_verification_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late AuthenticationCubit authenticationCubit;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
    authenticationCubit = AuthenticationCubit()
      ..authService = mockAuthService
      ..secureStorageService = mockSecureStorageService;
  });

  tearDown(() {
    authenticationCubit.close();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthenticationCubit>(
      create: (_) => authenticationCubit,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: const LoginScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/register': (context) => const RegistrationScreen(),
        },
      ),
    );
  }

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

          await tester.pumpWidget(createWidgetUnderTest());

          // Perform the form validation and submission
          await tester.enterText(
              find.byType(TextFormField).at(0), 'test10@example.com');
          await tester.enterText(
              find.byType(TextFormField).at(1), 'password123');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle(const Duration(seconds: 1));

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
          await tester.pumpWidget(createWidgetUnderTest());

          // Verify the initial state of the screen
          expect(find.text('Login'), findsNWidgets(2));
          expect(find.byType(TextFormField),
              findsNWidgets(2)); // email and password fields
          expect(find.byType(ElevatedButton), findsOneWidget);
        },
      );

      // Testing how the form reacts to user actions
      testWidgets(
        'Form validation works correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

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

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(
            find.byType(TextFormField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(find.text('Failed to login: Exception: Login failed'),
            findsOneWidget);
      });
    },
  );
}
