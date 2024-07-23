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

    setUp(() {
      mockTaskBox = MockBox();
      taskBloc = TaskBloc(mockTaskBox);

      testTask = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'A description',
        status: 'pending',
        dueDate: DateTime(2024, 7, 23),
        tags: const ['tag1'],
      );
    });

    test('initial state is TaskInitial', () {
      expect(taskBloc.state, TaskInitial());
    });

    group('LoadTasks', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskLoaded] when tasks are loaded successfully',
        build: () {
          when(mockTaskBox.values).thenReturn([testTask]);

          return taskBloc;
        },
        act: (bloc) => bloc.add(LoadTasks()),
        expect: () => [
          TaskLoading(),
          TaskLoaded([testTask]),
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
          when(mockTaskBox.values).thenReturn([testTask]);
          return taskBloc;
        },
        act: (bloc) => bloc.add(AddTask(testTask)),
        expect: () => [
          TaskLoaded([testTask]),
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

    group('DeleteTask', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoaded] when a task is deleted successfully',
        build: () {
          when(mockTaskBox.delete(any)).thenAnswer((_) async {});
          when(mockTaskBox.values).thenReturn([]);
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
  });
}
