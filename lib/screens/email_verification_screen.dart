import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Please check your email for a verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _resendVerificationEmail(context),
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _checkUserStatus(context),
                child: const Text('Check User Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resendVerificationEmail(BuildContext context) async {
    await context
        .read<AuthenticationCubit>()
        .resendVerificationEmail(email: email);
  }

  void _checkUserStatus(BuildContext context) async {
    if (!context.mounted) return;

    await context.read<AuthenticationCubit>().getCurrentUser().then((user) {
      if (user?.isVerified == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed: Email is not verified'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((error) {
      // Handle any potential errors
      debugPrint('Error while checking user status: $error');
    });
  }
}
