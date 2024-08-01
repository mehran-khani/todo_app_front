part of 'task_list_bloc.dart';

sealed class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object> get props => [];
}

final class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListLoaded extends TaskListState {
  final List<TaskListModel> taskLists;

  const TaskListLoaded(this.taskLists);

  @override
  List<Object> get props => [taskLists];
}

class TaskListEmpty extends TaskListState {
  final String message;

  const TaskListEmpty({required this.message});

  @override
  List<Object> get props => [message];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object> get props => [message];
}
