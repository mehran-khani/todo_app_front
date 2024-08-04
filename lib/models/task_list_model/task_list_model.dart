import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:to_do_application/models/task_model/task_model.dart';

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
  final String color;

  @HiveField(4)
  final String icon;

  const TaskListModel({
    required this.id,
    required this.name,
    required this.tasks,
    required this.color,
    required this.icon,
  });

  @override
  List<Object> get props => [id, name, tasks, color, icon];

  @override
  bool? get stringify => true;
}
