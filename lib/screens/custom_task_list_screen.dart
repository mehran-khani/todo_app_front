import 'package:flutter/material.dart';
import 'package:to_do_application/helpers/color_utils.dart';
import 'package:to_do_application/helpers/icon_utils.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/screens/home_screen_widget/task_list_widget.dart';

class CustomTaskListScreen extends StatelessWidget {
  final TaskListModel taskList;

  const CustomTaskListScreen({super.key, required this.taskList});

  @override
  Widget build(BuildContext context) {
    final TaskListIcon taskIcon = TaskListIcon.values.firstWhere(
        (e) => e.name == taskList.icon,
        orElse: () => TaskListIcon.listBullet);
    final TaskListColor taskColor = TaskListColor.values.firstWhere(
        (e) => e.name == taskList.color,
        orElse: () => TaskListColor.defaultColor);
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'icon ${taskList.id}',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: taskColor.color),
                child: Icon(
                  taskIcon.iconData,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Text(taskList.name),
        ],
      )),
      body: TaskListWidget(tasks: taskList.tasks),
    );
  }
}
