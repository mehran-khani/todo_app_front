import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/helpers/date_time_extensions.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

enum TaskCategory {
  today,
  scheduled,
  all,
  flagged,
  complete,
}

class TaskSummaryList extends StatelessWidget {
  const TaskSummaryList({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2,
      ),
      itemCount: TaskCategory.values.length,
      itemBuilder: (context, index) {
        final category = TaskCategory.values[index];
        return TaskSummaryItem(category: category);
      },
    );
  }
}

class TaskSummaryItem extends StatelessWidget {
  final TaskCategory category;

  const TaskSummaryItem({super.key, required this.category});

  get color => _getColor(category);
  get icon => _getIcon(category);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final taskCount =
            state is TaskLoaded ? _getTaskCount(category, state.tasks) : 0;

        return Card(
          elevation: 4.0,
          child: InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/taskList',
                arguments: {
                  'category': category,
                  'tag': null,
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 15, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white),
                        ),
                      ),
                      Text('$taskCount')
                    ],
                  ),
                  Text(
                    '${category.name[0].toUpperCase()}${category.name.substring(1)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.today:
        return Colors.blue;
      case TaskCategory.scheduled:
        return Colors.red;
      case TaskCategory.all:
        return Colors.black;
      case TaskCategory.flagged:
        return Colors.orange;
      case TaskCategory.complete:
        return Colors.green;
      default:
        return Colors.blue; // Default color
    }
  }

  IconData _getIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.today:
        return CupertinoIcons.sun_max;
      case TaskCategory.scheduled:
        return CupertinoIcons.calendar;
      case TaskCategory.all:
        return CupertinoIcons.tray_fill;
      case TaskCategory.flagged:
        return CupertinoIcons.flag;
      case TaskCategory.complete:
        return CupertinoIcons.check_mark;
      default:
        return CupertinoIcons.question; // Default icon
    }
  }

  int _getTaskCount(TaskCategory category, List<TaskModel> tasks) {
    switch (category) {
      case TaskCategory.today:
        return tasks.where((task) => task.dueDate.isToday()).length;
      case TaskCategory.scheduled:
        return tasks
            .where(
                (task) => task.dueDate.isFuture() && task.status != 'completed')
            .length;
      case TaskCategory.flagged:
        return tasks.where((task) => task.isFlagged).length;
      case TaskCategory.complete:
        return tasks.where((task) => task.status == 'complete').length;
      case TaskCategory.all:
      default:
        return tasks.length;
    }
  }
}
