part of 'task_list_bloc.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object> get props => [];
}

class LoadTaskLists extends TaskListEvent {}

class AddTaskList extends TaskListEvent {
  final TaskListModel taskList;

  const AddTaskList(this.taskList);

  @override
  List<Object> get props => [taskList];
}

class UpdateTaskList extends TaskListEvent {
  final TaskListModel taskList;

  const UpdateTaskList(this.taskList);

  @override
  List<Object> get props => [taskList];
}

class DeleteTaskList extends TaskListEvent {
  final String name;

  const DeleteTaskList(this.name);

  @override
  List<Object> get props => [name];
}
