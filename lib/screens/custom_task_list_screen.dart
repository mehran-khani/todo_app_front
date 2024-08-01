import 'package:flutter/material.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/screens/home_screen_widget/task_list_widget.dart';

class CustomTaskListScreen extends StatelessWidget {
  final TaskListModel taskList;

  const CustomTaskListScreen({super.key, required this.taskList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(taskList.name)),
      body: TaskListWidget(tasks: taskList.tasks),
    );
  }
}
