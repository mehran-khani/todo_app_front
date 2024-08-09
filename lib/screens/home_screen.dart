import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_list_modal.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_modal.dart';
import 'package:to_do_application/screens/home_screen_widget/custom_task_list_section.dart';
import 'package:to_do_application/screens/home_screen_widget/search_field.dart';
import 'package:to_do_application/screens/home_screen_widget/tag_section.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Color _bottomAppBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<TaskBloc>().add(TaskReset());
    context.read<TaskListBloc>().add(LoadTaskLists());
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double scrollThreshold = 10.0;

      if (offset >= maxScrollExtent - scrollThreshold) {
        // User has scrolled near the end of the screen
        setState(() {
          _bottomAppBarColor = Colors.transparent;
        });
      } else if (offset > scrollThreshold) {
        // User has scrolled down past the threshold
        setState(() {
          _bottomAppBarColor =
              Colors.transparent.withAlpha(12); // Change color when scrolled
        });
      } else {
        // User is near the top
        setState(() {
          _bottomAppBarColor =
              Colors.transparent; // Transparent when at the top
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                try {
                  context.read<AuthenticationCubit>().logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              },
              icon: const Icon(
                CupertinoIcons.square_arrow_left,
                size: 26,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchField(),
              SizedBox(height: 16.0),
              TaskSummaryList(),
              SizedBox(height: 16.0),
              CustomTaskListSection(),
              SizedBox(height: 16.0),
              TagSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: _bottomAppBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const CreateTaskModal(),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'New Task',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const CreateTaskListModal(),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'Add List',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
