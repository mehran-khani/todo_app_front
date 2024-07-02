import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import 'registration_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<NavigatorObserver>(),
  MockSpec<SecureStorageService>()
])
void main() {
  group(
    'RegistrationScreen',
    () {
      // initializing the mock and AuthenticationCubit for authentication logic tests
      late MockAuthService mockAuthService;
      late AuthenticationCubit authenticationCubit;

      setUp(
        () {
          mockAuthService = MockAuthService();
          authenticationCubit = AuthenticationCubit();
          authenticationCubit.authService = mockAuthService;
        },
      );

      tearDown(
        () {
          authenticationCubit.close();
        },
      );

      testWidgets('Successful registration redirects to HomeScreen',
          (WidgetTester tester) async {
        // Mock successful registration response
        when(mockAuthService.register(any, any, any, any)).thenAnswer(
          (_) async => {'message': 'User registered successfully.'},
        );

        await tester.pumpWidget(
          BlocProvider<AuthenticationCubit>(
            create: (_) => authenticationCubit..checkAuthStatus(),
            child: MaterialApp(
              home: const RegistrationScreen(),
              routes: {
                '/home': (_) => const HomeScreen(),
              },
            ),
          ),
        );

        // Fill in the registration form
        await tester.enterText(
            find.byType(TextFormField).at(0), 'test10@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

        // Tap the register button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle(); // Wait for animations to complete

        // Verify navigation to HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

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
          expect(find.text('Register'), findsNWidgets(2));
          expect(find.byType(TextFormField), findsNWidgets(4));
          expect(find.byType(ElevatedButton), findsOneWidget);
        },
      );

      // testing the how how does our form reacts to users actions
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
          await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text('Please enter your email'), findsNothing);
          expect(find.text('Please enter your password'), findsNothing);
          expect(find.text('Please confirm your password'), findsNothing);
          expect(find.text('Please enter your name'), findsNothing);
        },
      );

      // testing registeratoin logic
      testWidgets(
        'Successful registration navigates to HomeScreen and shows success message',
        (WidgetTester tester) async {
          // Stub navigator methods to avoid MissingStubError.
          // when(mockObserver.didPush(any, any)).thenReturn(null);
          when(mockAuthService.register(any, any, any, any)).thenAnswer(
            (_) async {
              return {
                'message':
                    'User registered successfully. Please check your email for verification link.',
                'access': 'your_access_token_value',
                'refresh': 'your_refresh_token_value',
              };
            },
          );
          await tester.pumpWidget(
            BlocProvider<AuthenticationCubit>(
              create: (_) => authenticationCubit..checkAuthStatus(),
              child: MaterialApp(
                home: const RegistrationScreen(),
                routes: {
                  '/home': (_) => const HomeScreen(),
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
          await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.byType(SnackBar), findsOneWidget);

          // Wait for the registration to complete
          await tester.pump(const Duration(seconds: 2));

          // Check for success message in SnackBar
          expect(
              find.text(
                  'User registered successfully. Please check your email for verification link.'),
              findsOneWidget);

          // Check for HomeScreen after successful registration
          expect(find.byType(HomeScreen), findsOneWidget);
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
        await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(find.text('Failed to register: Exception: Registration failed'),
            findsOneWidget);
      });
    },
  );
}
