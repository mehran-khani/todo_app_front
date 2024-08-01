import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/screens/custom_task_list_screen.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';

class CustomTaskListSection extends StatelessWidget {
  const CustomTaskListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Lists',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        BlocBuilder<TaskListBloc, TaskListState>(
          builder: (context, state) {
            if (state is TaskListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskListLoaded) {
              return Column(
                children: state.taskLists.map((taskList) {
                  return ListTile(
                    title: Text(taskList.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomTaskListScreen(taskList: taskList),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            } else if (state is TaskListError) {
              return const Center(child: Text('Failed to load task lists'));
            } else if (state is TaskListEmpty) {
              //TODO: Empty state should be handle with an animation
              return Center(child: Text(state.message));
            } else if (state is TaskListInitial) {
              context.read<TaskListBloc>().add(LoadTaskLists());
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ],
    );
  }
}
