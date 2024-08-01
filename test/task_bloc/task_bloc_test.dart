import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

import 'task_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Box<TaskModel>>()])
void main() {
  group('TaskBloc', () {
    late TaskBloc taskBloc;
    late MockBox mockTaskBox;
    late TaskModel testTask;
    late TaskModel anotherTask;
    late TaskModel updatedTaskWithStatus;
    late TaskModel updatedTaskWithFlag;
    late List<TaskModel> taskModelList;

    setUp(() {
      mockTaskBox = MockBox();
      taskBloc = TaskBloc(mockTaskBox);

      testTask = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'A description',
        status: 'incomplete',
        dueDate: DateTime(2024, 7, 23),
        tags: const ['tag1'],
      );

      anotherTask = TaskModel(
        id: '2',
        title: 'Another Task',
        description: 'Another description',
        status: 'completed',
        dueDate: DateTime(2024, 7, 24),
        tags: const ['tag2'],
      );

      taskModelList = [testTask];
      updatedTaskWithStatus = testTask.copyWith(status: 'completed');

      updatedTaskWithFlag = testTask.copyWith(isFlagged: true);
    });

    test('initial state is TaskInitial', () {
      expect(taskBloc.state, TaskInitial());
    });

    group('LoadTasks', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskLoaded] when tasks are loaded successfully',
        build: () {
          when(mockTaskBox.values).thenReturn([testTask, anotherTask]);

          return taskBloc;
        },
        act: (bloc) => bloc.add(LoadTasks()),
        expect: () => [
          TaskLoading(),
          TaskLoaded([testTask, anotherTask]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskError] when tasks loading fails',
        build: () {
          when(mockTaskBox.values).thenThrow(Exception('Failed to load tasks'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(LoadTasks()),
        expect: () => [
          TaskLoading(),
          const TaskError("Failed to load tasks"),
        ],
      );
    });

    group('AddTask', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when a task is added successfully',
        build: () {
          when(mockTaskBox.values).thenReturn(taskModelList);
          when(mockTaskBox.put(any, anotherTask)).thenAnswer(
            (_) async {
              taskModelList.add(anotherTask);
            },
          );
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(AddTask(anotherTask));
        },
        expect: () => [
          TaskLoaded(taskModelList),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when adding a task fails',
        build: () {
          when(mockTaskBox.put(any, testTask))
              .thenThrow(Exception('Failed to add task'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(AddTask(testTask)),
        expect: () => [
          const TaskError("Failed to add task"),
        ],
      );
    });

    group('UpdateTask', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when a task is updated successfully',
        build: () {
          when(mockTaskBox.put(any, testTask)).thenAnswer((_) async {});
          when(mockTaskBox.values).thenReturn([testTask]);
          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTask(testTask)),
        expect: () => [
          TaskLoaded([testTask]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when updating a task fails',
        build: () {
          when(mockTaskBox.put(any, testTask))
              .thenThrow(Exception('Failed to update task'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTask(testTask)),
        expect: () => [
          const TaskError("Failed to update task"),
        ],
      );
    });

    group('UpdateTaskStatus', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when task status is updated successfully',
        build: () {
          when(mockTaskBox.get(testTask.id)).thenReturn(testTask);

          when(mockTaskBox.put(testTask.id, updatedTaskWithStatus))
              .thenAnswer((_) async {
            taskModelList.remove(testTask);
            taskModelList.add(updatedTaskWithStatus);
          });

          when(mockTaskBox.values).thenReturn(taskModelList);

          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskStatus(testTask.id, 'completed')),
        expect: () => [
          TaskLoaded(taskModelList),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when updating task status fails',
        build: () {
          when(mockTaskBox.get(testTask.id)).thenReturn(testTask);
          when(mockTaskBox.put(testTask.id, any))
              .thenThrow(Exception('Failed to update task status'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskStatus(testTask.id, 'completed')),
        expect: () => [
          const TaskError("Failed to update task status"),
        ],
      );
    });

    group('UpdateTaskFlag', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when task flag is updated successfully',
        build: () {
          when(mockTaskBox.get(testTask.id)).thenReturn(testTask);
          when(mockTaskBox.put(testTask.id, updatedTaskWithFlag))
              .thenAnswer((_) async {
            taskModelList.remove(testTask);
            taskModelList.add(updatedTaskWithFlag);
          });
          when(mockTaskBox.values).thenReturn(taskModelList);
          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskFlag(testTask.id, true)),
        expect: () => [
          TaskLoaded([updatedTaskWithFlag]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when updating task flag fails',
        build: () {
          when(mockTaskBox.get(testTask.id)).thenReturn(testTask);
          when(mockTaskBox.put(testTask.id, any))
              .thenThrow(Exception('Failed to update task flag'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskFlag(testTask.id, true)),
        expect: () => [
          const TaskError("Failed to update task flag"),
        ],
      );
    });

    group('DeleteTask', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when a task is deleted successfully',
        build: () {
          taskModelList = [testTask];
          when(mockTaskBox.delete(testTask)).thenAnswer((_) async {
            taskModelList = [];
          });
          mockTaskBox.delete(testTask);
          when(mockTaskBox.values).thenReturn(taskModelList);
          return taskBloc;
        },
        act: (bloc) => bloc.add(const DeleteTask('1')),
        expect: () => [
          const TaskLoaded([]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when deleting a task fails',
        build: () {
          when(mockTaskBox.delete(any))
              .thenThrow(Exception('Failed to delete task'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(const DeleteTask('1')),
        expect: () => [
          const TaskError("Failed to delete task"),
        ],
      );
    });

    group('SearchTasks', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] with filtered tasks when a search is performed successfully',
        build: () {
          when(mockTaskBox.values).thenReturn([testTask, anotherTask]);
          return taskBloc;
        },
        act: (bloc) => bloc.add(const SearchTasks('Test')),
        expect: () => [
          TaskLoaded([testTask]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when searching tasks fails',
        build: () {
          when(mockTaskBox.values)
              .thenThrow(Exception('Failed to search tasks'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(const SearchTasks('Test')),
        expect: () => [
          const TaskError("Failed to search tasks"),
        ],
      );
    });

    group('FilterTasksByTag', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] with filtered tasks by tag when a filter is applied successfully',
        build: () {
          when(mockTaskBox.values).thenReturn([testTask, anotherTask]);
          return taskBloc;
        },
        act: (bloc) => bloc.add(const FilterTasksByTag('tag1')),
        expect: () => [
          TaskLoaded([testTask]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when filtering tasks by tag fails',
        build: () {
          when(mockTaskBox.values)
              .thenThrow(Exception('Failed to filter tasks by tag'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(const FilterTasksByTag('tag1')),
        expect: () => [
          const TaskError("Failed to filter tasks by tag"),
        ],
      );
    });

    group('TaskReset', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] with all tasks when reset is performed successfully',
        build: () {
          when(mockTaskBox.values).thenReturn([testTask, anotherTask]);
          return taskBloc;
        },
        act: (bloc) => bloc.add(TaskReset()),
        expect: () => [
          TaskLoaded([testTask, anotherTask]),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskError] when resetting tasks fails',
        build: () {
          when(mockTaskBox.values)
              .thenThrow(Exception('Failed to reset tasks'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(TaskReset()),
        expect: () => [
          const TaskError("Failed to reset tasks"),
        ],
      );
    });
  });
}
