import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen'),
      ),
      body: Center(
        child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is LoggedOut) {
              Navigator.pushReplacementNamed(context, '/register');
            } else if (state is Failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                ),
              );
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () async {
                context.read<AuthenticationCubit>().logout();
              },
              child: Text('Log out'),
            );
          },
        ),
      ),
    );
  }
}
