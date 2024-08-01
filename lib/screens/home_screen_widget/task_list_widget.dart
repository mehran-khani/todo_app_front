import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

//TODO: Not completed yet wirte the tests first and complete the widget
class TaskListWidget extends StatelessWidget {
  final List<TaskModel> tasks;

  const TaskListWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      //TODO: handle when there is not tasks to show in any category
      return const Center(child: Text('No tasks found.'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id), // Unique key for each item
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              context.read<TaskBloc>().add(DeleteTask(task.id));
            }
          },
          background: Container(
            color: Colors.transparent,
          ),
          secondaryBackground: Container(
            color: Colors.red,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  CupertinoIcons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.dueDate.toString()),
            leading: IconButton(
              onPressed: () {
                final newStatus =
                    task.status == 'complete' ? 'incomplete' : 'complete';
                context
                    .read<TaskBloc>()
                    .add(UpdateTaskStatus(task.id, newStatus));
              },
              icon: Icon(task.status == 'complete'
                  ? CupertinoIcons.check_mark_circled
                  : CupertinoIcons.circle),
            ),
            trailing: IconButton(
              onPressed: () {
                final newFlagStatus = !task.isFlagged;
                context
                    .read<TaskBloc>()
                    .add(UpdateTaskFlag(task.id, newFlagStatus));
              },
              icon: Icon(task.isFlagged
                  ? CupertinoIcons.flag_fill
                  : CupertinoIcons.flag),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
