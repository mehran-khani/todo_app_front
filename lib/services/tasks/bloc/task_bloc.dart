import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:to_do_application/models/task_model/task_model.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Box<TaskModel> taskBox;
  String? _activeFilterTag;

  TaskBloc(this.taskBox) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<UpdateTaskFlag>(_onUpdateTaskFlag);
    on<DeleteTask>(_onDeleteTask);
    on<SearchTasks>(_onSearchTasks);
    on<FilterTasksByTag>(_onFilterTasksByTag);
    on<TaskReset>(_onTaskReset);

    add(LoadTasks());
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(TaskLoading());
    try {
      final tasks = taskBox.values.toList();
      if (_activeFilterTag != null) {
        final filteredTasks = tasks
            .where((task) => task.tags.contains(_activeFilterTag!))
            .toList();
        emit(TaskLoaded(filteredTasks));
      } else {
        if (tasks.isEmpty) {
          emit(
            const TaskEmpty(message: 'You do not have any Task'),
          );
        } else {
          emit(TaskLoaded(tasks));
        }
      }
    } catch (e) {
      emit(const TaskError("Failed to load tasks"));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    try {
      taskBox.put(event.task.id, event.task);
      _reloadTasks(emit);
    } catch (e) {
      emit(const TaskError("Failed to add task"));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    try {
      taskBox.put(event.task.id, event.task);
      _reloadTasks(emit);
    } catch (e) {
      emit(const TaskError("Failed to update task"));
    }
  }

  void _onUpdateTaskStatus(UpdateTaskStatus event, Emitter<TaskState> emit) {
    try {
      final task = taskBox.get(event.taskId);
      if (task != null) {
        final updatedTask = task.copyWith(status: event.status);
        taskBox.put(updatedTask.id, updatedTask);
        _reloadTasks(emit);
      } else {
        emit(const TaskError("Task not found"));
      }
    } catch (e) {
      emit(const TaskError("Failed to update task status"));
    }
  }

  void _onUpdateTaskFlag(UpdateTaskFlag event, Emitter<TaskState> emit) {
    try {
      final task = taskBox.get(event.taskId);
      if (task != null) {
        final updatedTask = task.copyWith(isFlagged: event.isFlagged);
        taskBox.put(updatedTask.id, updatedTask);
        _reloadTasks(emit);
      } else {
        emit(const TaskError("Task not found"));
      }
    } catch (e) {
      emit(const TaskError("Failed to update task flag"));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    try {
      taskBox.delete(event.id);
      _reloadTasks(emit);
    } catch (e) {
      emit(const TaskError("Failed to delete task"));
    }
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    try {
      final allTasks = taskBox.values.toList();
      final filteredTasks = allTasks
          .where((task) =>
              task.title.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(TaskLoaded(filteredTasks));
    } catch (e) {
      emit(const TaskError("Failed to search tasks"));
    }
  }

  void _onFilterTasksByTag(FilterTasksByTag event, Emitter<TaskState> emit) {
    try {
      _activeFilterTag = event.tag;
      final allTasks = taskBox.values.toList();
      final filteredTasks =
          allTasks.where((task) => task.tags.contains(event.tag)).toList();
      emit(TaskLoaded(filteredTasks));
    } catch (e) {
      emit(const TaskError("Failed to filter tasks by tag"));
    }
  }

  void _onTaskReset(TaskReset event, Emitter<TaskState> emit) {
    _activeFilterTag = null;
    try {
      final allTasks = taskBox.values.toList();
      emit(TaskLoaded(allTasks));
    } catch (e) {
      //emit(TaskError('Failed to reset tasks: ${e.toString()}'));
      emit(const TaskError('Failed to reset tasks'));
    }
  }

  void _reloadTasks(Emitter<TaskState> emit) {
    try {
      if (_activeFilterTag != null) {
        final allTasks = taskBox.values.toList();
        final filteredTasks = allTasks
            .where((task) => task.tags.contains(_activeFilterTag!))
            .toList();
        emit(TaskLoaded(filteredTasks));
      } else {
        final tasks = taskBox.values.toList();
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(const TaskError("Failed to reload tasks"));
    }
  }
}
