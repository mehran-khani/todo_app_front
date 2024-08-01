import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:to_do_application/models/task_model/task_model.dart'; // Adjust the import as needed

part 'task_list_model.g.dart';

@HiveType(typeId: 2)
class TaskListModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<TaskModel> tasks;

  @HiveField(3)
  final String theme;

  @HiveField(4)
  final IconData icon;

  const TaskListModel({
    required this.id,
    required this.name,
    required this.tasks,
    required this.theme,
    required this.icon,
  });

  @override
  List<Object> get props => [id, name, tasks, theme, icon];

  @override
  bool? get stringify => true;
}
