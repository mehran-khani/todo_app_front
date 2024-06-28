import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

import 'registration_screen_test.mocks.dart';

@GenerateMocks([AuthService],
    customMocks: [MockSpec<AuthService>(as: #CustomMockAuthService)])
@GenerateMocks([
  AuthenticationCubit
], customMocks: [
  MockSpec<AuthenticationCubit>(as: #CustomMockAuthenticationCubit)
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
      testWidgets('Successful registration shows success message',
          (WidgetTester tester) async {
        // Mock the AuthService's register method to return a success message
        when(mockAuthService.register(any, any, any, any))
            .thenAnswer((_) async {
          return {
            'message':
                'User registered successfully. Please check your email for verification link.'
          };
        });

        // Build the widget tree with the mocked AuthenticationCubit
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => authenticationCubit,
              child: const RegistrationScreen(),
            ),
          ),
        );

        // Enter text into the TextFormField widgets
        await tester.enterText(
            find.byType(TextFormField).at(0), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

        // Tap the ElevatedButton to trigger registration
        await tester.tap(find.byType(ElevatedButton));
        // Allow time for the UI to update after tapping the button
        await tester.pump();

        // Verify that the success message appears on the screen
        expect(
            find.text(
                'User registered successfully. Please check your email for verification link.'),
            findsOneWidget);
      });

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

        expect(find.text('Failed to register: Exception: Registration failed'),
            findsOneWidget);
      });
    },
  );
}

// // Mocking the AuthService
// class MockAuthService extends Mock implements AuthService {}

// void main() {
//   group('RegistrationScreen', () {
//     late MockAuthService mockAuthService;
//     late AuthenticationCubit authenticationCubit;

//     setUp(() {
//       mockAuthService = MockAuthService();
//       authenticationCubit = AuthenticationCubit();
//     });

//     tearDown(() {
//       authenticationCubit.close();
//     });

//     testWidgets('RegistrationScreen displays correctly', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider(
//             create: (context) => authenticationCubit,
//             child: RegistrationScreen(),
//           ),
//         ),
//       );

//       expect(find.text('Register'), findsOneWidget);
//       expect(find.byType(TextFormField), findsNWidgets(4));
//       expect(find.byType(ElevatedButton), findsOneWidget);
//     });

//     testWidgets('Form validation works correctly', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider(
//             create: (context) => authenticationCubit,
//             child: RegistrationScreen(),
//           ),
//         ),
//       );

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('Please enter your email'), findsOneWidget);
//       expect(find.text('Please enter your password'), findsOneWidget);
//       expect(find.text('Please confirm your password'), findsOneWidget);
//       expect(find.text('Please enter your name'), findsOneWidget);

//       await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
//       await tester.enterText(find.byType(TextFormField).at(1), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(2), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('Please enter your email'), findsNothing);
//       expect(find.text('Please enter your password'), findsNothing);
//       expect(find.text('Please confirm your password'), findsNothing);
//       expect(find.text('Please enter your name'), findsNothing);
//     });

//     testWidgets('Successful registration shows success message', (WidgetTester tester) async {
//       when(mockAuthService.register(any, any, any, any)).thenAnswer((_) async {
//         return {'message': 'User registered successfully. Please check your email for verification link.'};
//       });

//       final authenticationCubitWithMockService = AuthenticationCubit()..register(
//         email: 'test@example.com',
//         password: 'password123',
//         confirmPassword: 'password123',
//         name: 'Mehran',
//       );

//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider(
//             create: (context) => authenticationCubitWithMockService,
//             child: RegistrationScreen(),
//           ),
//         ),
//       );

//       await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
//       await tester.enterText(find.byType(TextFormField).at(1), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(2), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('User registered successfully. Please check your email for verification link.'), findsOneWidget);
//     });

//     testWidgets('Failed registration shows error message', (WidgetTester tester) async {
//       when(mockAuthService.register(any, any, any, any)).thenThrow(Exception('Registration failed'));

//       final authenticationCubitWithMockService = AuthenticationCubit()..register(
//         email: 'test@example.com',
//         password: 'password123',
//         confirmPassword: 'password123',
//         name: 'Mehran',
//       );

//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider(
//             create: (context) => authenticationCubitWithMockService,
//             child: RegistrationScreen(),
//           ),
//         ),
//       );

//       await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
//       await tester.enterText(find.byType(TextFormField).at(1), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(2), 'password123');
//       await tester.enterText(find.byType(TextFormField).at(3), 'Mehran');

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('Failed to register: Exception: Registration failed'), findsOneWidget);
//     });
//   });
// }
