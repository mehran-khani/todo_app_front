part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class LoadTasks extends TaskEvent {}

class TaskReset extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final String status; // 'complete' or 'incomplete'

  const UpdateTaskStatus(this.taskId, this.status);

  @override
  List<Object> get props => [taskId, status];
}

class UpdateTaskFlag extends TaskEvent {
  final String taskId;
  final bool isFlagged;

  const UpdateTaskFlag(this.taskId, this.isFlagged);

  @override
  List<Object> get props => [taskId, isFlagged];
}

class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object> get props => [id];
}

class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object> get props => [query];
}

class FilterTasksByTag extends TaskEvent {
  final String? tag;

  const FilterTasksByTag(this.tag);

  @override
  List<Object?> get props => [tag];
}
