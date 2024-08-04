import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Box<TaskListModel> taskListBox;

  TaskListBloc(this.taskListBox) : super(TaskListInitial()) {
    on<LoadTaskLists>(_onLoadTaskLists);
    on<AddTaskList>(_onAddTaskList);
    on<UpdateTaskList>(_onUpdateTaskList);
    on<DeleteTaskList>(_onDeleteTaskList);

    add(LoadTaskLists());
  }

  void _onLoadTaskLists(LoadTaskLists event, Emitter<TaskListState> emit) {
    emit(TaskListLoading());
    try {
      final taskLists = taskListBox.values.toList();
      if (taskLists.isEmpty) {
        emit(
          const TaskListEmpty(message: 'You do not have any Task List'),
        );
      } else {
        emit(
          TaskListLoaded(taskLists),
        );
      }
    } catch (e) {
      emit(
        const TaskListError("Failed to load task lists"),
      );
    }
  }

  void _onAddTaskList(AddTaskList event, Emitter<TaskListState> emit) {
    try {
      taskListBox.put(event.taskList.name, event.taskList);
      final taskLists = taskListBox.values.toList();
      emit(TaskListLoaded(taskLists));
    } catch (e) {
      emit(const TaskListError("Failed to add task list"));
    }
  }

  void _onUpdateTaskList(UpdateTaskList event, Emitter<TaskListState> emit) {
    try {
      taskListBox.put(event.taskList.name, event.taskList);
      final taskLists = taskListBox.values.toList();
      emit(TaskListLoaded(taskLists));
    } catch (e) {
      emit(const TaskListError("Failed to update task list"));
    }
  }

//TODO: I will change the delete method to delete task lists with their id instead of name cuz it may lead to deleting multiple with same name
  void _onDeleteTaskList(
      DeleteTaskList event, Emitter<TaskListState> emit) async {
    try {
      await taskListBox.delete(event.name);
      final taskLists = taskListBox.values.toList();
      emit(TaskListLoaded(taskLists));
    } catch (e) {
      emit(const TaskListError("Failed to delete task list"));
    }
  }
}
