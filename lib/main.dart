import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationCubit>(
        create: (context) => AuthenticationCubit()..checkAuthStatus(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const Main(),
      home: BlocProvider(
        create: (context) => AuthenticationCubit()..checkAuthStatus(),
        child: const RegistrationScreen(),
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is LoggedOut) {
          print(state.toString());
          Navigator.pushReplacementNamed(context, '/register');
        } else if (state is Success) {
          print(state.toString());
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      builder: (context, state) {
        // You can add loading indicators or initial screens here if needed
        return const SizedBox
            .shrink(); // Placeholder; you can return any loading widget here
      },
    );
  }
}
