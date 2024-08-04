import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/screens/custom_task_list_screen.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:to_do_application/helpers/icon_utils.dart';
import 'package:to_do_application/helpers/color_utils.dart';

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
              final List<TaskListModel> taskLists = state.taskLists;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(
                    taskLists.length,
                    (index) {
                      final taskList = taskLists[index];
                      // Use the TaskListColor and TaskListicon enums to get the color and icon
                      final TaskListColor taskColor = TaskListColor.values
                          .firstWhere((e) => e.name == taskList.color,
                              orElse: () => TaskListColor.defaultColor);
                      final TaskListIcon taskIcon = TaskListIcon.values
                          .firstWhere((e) => e.name == taskList.icon,
                              orElse: () => TaskListIcon.listBullet);

                      return Dismissible(
                        // Make sure `id` is unique for each taskList
                        key: Key(taskList.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          // delete the task list
                          context
                              .read<TaskListBloc>()
                              .add(DeleteTaskList(taskList.name));
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: taskColor.color,
                                ),
                                child: Icon(
                                  taskIcon.iconData,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(taskList.name),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomTaskListScreen(
                                        taskList: taskList),
                                  ),
                                );
                              },
                            ),
                            if (index < taskLists.length - 1)
                              const Divider(
                                indent: 16.0,
                                height: 1.0,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (state is TaskListError) {
              return const Center(child: Text('Failed to load task lists'));
            } else if (state is TaskListEmpty) {
              // TODO: Empty state should be handled with an animation
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
