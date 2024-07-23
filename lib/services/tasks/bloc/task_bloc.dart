import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:to_do_application/models/task_model/task_model.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Box<TaskModel> taskBox;

  TaskBloc(this.taskBox) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(TaskLoading());
    try {
      final tasks = taskBox.values.toList();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(const TaskError("Failed to load tasks"));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    try {
      taskBox.put(event.task.id, event.task);
      final tasks = taskBox.values.toList();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(const TaskError("Failed to add task"));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    try {
      taskBox.put(event.task.id, event.task);
      final tasks = taskBox.values.toList();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(const TaskError("Failed to update task"));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    try {
      taskBox.delete(event.id);
      final tasks = taskBox.values.toList();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(const TaskError("Failed to delete task"));
    }
  }
}
