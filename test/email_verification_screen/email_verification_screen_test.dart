import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/user_model/user_model.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';
import 'package:to_do_application/services/authentication/auth_service.dart';
import 'package:to_do_application/screens/email_verification_screen.dart';

import 'email_verification_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthService>(), MockSpec<SecureStorageService>()])
void main() {
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late AuthenticationCubit authenticationCubit;

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
    authenticationCubit = AuthenticationCubit()
      ..authService = mockAuthService
      ..secureStorageService = mockSecureStorageService;
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthenticationCubit>(
      create: (_) => authenticationCubit,
      child: MaterialApp(
        home: const EmailVerificationScreen(email: 'test10@example.com'),
        routes: {
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }

  group(
    'Email Verification Screen Tests',
    () {
      testWidgets('displays verification message', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Please check your email for a verification link.'),
            findsOneWidget);
      });

      testWidgets('resends verification email on button press',
          (WidgetTester tester) async {
        when(mockAuthService.resendVerificationEmail('test10@example.com'))
            .thenAnswer((_) async =>
                {'message': 'Verification email sent successfully'});

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Resend Verification Email'));
        await tester.pump();

        expect(authenticationCubit.state, isA<Success>());

        expect(find.byType(SnackBar), findsOneWidget);
        expect((authenticationCubit.state as Success).message,
            'Verification email sent successfully');

        verify(authenticationCubit.resendVerificationEmail(
                email: 'test10@example.com'))
            .called(1);
      });

      testWidgets('checks user status on button press',
          (WidgetTester tester) async {
        // Ensure the mock reads and writes the token with the correct key
        when(mockSecureStorageService.writeToken('accessToken', 'token'))
            .thenAnswer((_) async => Future.value());
        when(mockSecureStorageService.readToken('accessToken'))
            .thenAnswer((_) async => Future.value('token'));

        // Write the token to the secure storage
        await mockSecureStorageService.writeToken('accessToken', 'token');
        final accessToken =
            await mockSecureStorageService.readToken('accessToken');

        when(mockAuthService.getCurrentUser(accessToken)).thenAnswer((_) async {
          return UserModel(
            email: 'test10@example.com',
            name: 'User',
            isVerified: true,
          );
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Check User Status'));
        await tester.pumpAndSettle();

        expect(authenticationCubit.state, isA<Authenticated>());
        expect((authenticationCubit.state as Authenticated).message,
            'Welcome User');
      });

      testWidgets('checks user status on button press failure',
          (WidgetTester tester) async {
        when(mockAuthService.getCurrentUser('token')).thenAnswer(
          (_) async => Future.value(
            UserModel(
              email: 'email',
              name: 'name',
              isVerified: false,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Check User Status'));
        await tester.pump();

        expect(authenticationCubit.state, isA<LoggedOut>());
      });

      testWidgets('navigates to HomeScreen if email is verified',
          (WidgetTester tester) async {
        when(mockSecureStorageService.writeToken('accessToken', 'token'))
            .thenAnswer((_) async => Future.value());
        when(mockSecureStorageService.readToken('accessToken'))
            .thenAnswer((_) async => Future.value('token'));

        await mockSecureStorageService.writeToken('accessToken', 'token');
        final accessToken =
            await mockSecureStorageService.readToken('accessToken');

        when(mockAuthService.getCurrentUser(accessToken)).thenAnswer((_) async {
          return UserModel(
            email: 'test10@example.com',
            name: 'User',
            isVerified: true,
          );
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Check User Status'));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('shows error message if email is not verified',
          (WidgetTester tester) async {
        when(mockAuthService.getCurrentUser('token')).thenAnswer((_) async {
          return UserModel(
            email: 'test10@example.com',
            name: 'User',
            isVerified: false,
          );
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Check User Status'));
        await tester.pump();

        expect(find.text('Failed: Email is not verified'), findsOneWidget);
      });
    },
  );
}
