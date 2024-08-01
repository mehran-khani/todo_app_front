import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/helpers/date_time_extensions.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/screens/home_screen_widget/task_list_widget.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

class TaskListScreen extends StatelessWidget {
  final TaskCategory category;
  final String? tag;

  const TaskListScreen({super.key, required this.category, this.tag});

  @override
  Widget build(BuildContext context) {
    if (tag != null) {
      context.read<TaskBloc>().add(FilterTasksByTag(tag!));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${category.name[0].toUpperCase()}${category.name.substring(1)}'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final List<TaskModel> tasks;
            if (tag == null) {
              print("No tag provided, filtering by category");
              switch (category) {
                case TaskCategory.today:
                  print("Filtering tasks for Today category");
                  final todayTasks = state.tasks.where((task) {
                    bool isToday = task.dueDate.isToday();
                    print("Task due date: ${task.dueDate}, isToday: $isToday");
                    return isToday;
                  }).toList();
                  tasks = todayTasks;
                  print(tasks);
                  break;

                case TaskCategory.scheduled:
                  tasks = state.tasks
                      .where((task) =>
                          task.dueDate.isFuture() && task.status != 'complete')
                      .toList();
                  break;
                case TaskCategory.flagged:
                  tasks = state.tasks.where((task) => task.isFlagged).toList();
                  break;
                case TaskCategory.complete:
                  tasks = state.tasks
                      .where((task) => task.status == 'complete')
                      .toList();
                  break;
                case TaskCategory.all:
                  // default:
                  tasks = state.tasks;
                  break;
              }
              print(
                  "Rendering TaskListWidget with ${tasks.length} tasks with no tag : $tasks");
              return TaskListWidget(tasks: tasks);
            } else {
              // Tasks are already filtered by tag through the Bloc
              print(
                  "Rendering TaskListWidget with ${state.tasks.length} tasks");
              return TaskListWidget(tasks: state.tasks);
            }
          } else if (state is TaskEmpty) {
            return Center(child: Text(state.message));
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
