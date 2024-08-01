import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/screens/email_verification_screen.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/screens/login_screen.dart';
import 'package:to_do_application/screens/registration_screen.dart';
import 'package:to_do_application/screens/task_list_screen.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskListModelAdapter());
  Hive.registerAdapter(TagModelAdapter());

  final taskBox = await Hive.openBox<TaskModel>('tasks');
  final taskListBox = await Hive.openBox<TaskListModel>('taskLists');
  final tagBox = await Hive.openBox<TagModel>('tags');

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationCubit>(
        create: (context) => AuthenticationCubit(),
      ),
      BlocProvider<TaskBloc>(
        create: (context) => TaskBloc(taskBox),
      ),
      BlocProvider<TaskListBloc>(
        create: (context) => TaskListBloc(taskListBox),
      ),
      BlocProvider<TagBloc>(
        create: (context) => TagBloc(tagBox),
      )
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
      home: const Main(),
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/taskList':
            final category = args?['category'] as TaskCategory?;
            final tag = args?['tag'] as String?;
            if (category != null) {
              return MaterialPageRoute(
                builder: (context) => TaskListScreen(
                  category: category,
                  tag: tag,
                ),
              );
            } else {
              //TODO: Handle the case where category is null
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Invalid Task List')),
                  body: const Center(child: Text('Category not provided')),
                ),
              );
            }
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegistrationScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case '/verify-email':
            final email = args?['email'] as String?;
            return MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(email: email ?? ''),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: const Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.user.isVerified) {
            return const HomeScreen();
          } else {
            return EmailVerificationScreen(email: state.user.email);
          }
        } else if (state is LoggedOut) {
          return const LoginScreen();
        } else if (state is Success) {
          context.read<AuthenticationCubit>().init();
        } else if (state is Registering) {
          return const RegistrationScreen();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
