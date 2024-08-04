import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';

import 'task_list_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Box<TaskListModel>>()])
void main() {
  group('TaskListBloc', () {
    late TaskListBloc taskListBloc;
    late MockBox mockBox;
    late TaskListModel taskList;
    late TaskListModel newTaskList;
    late TaskListModel updatedTaskList;
    late List<TaskListModel> taskListModelList;

    setUp(() {
      mockBox = MockBox();
      taskListBloc = TaskListBloc(mockBox);

      taskList = const TaskListModel(
        id: '1',
        name: 'Test TaskList',
        tasks: [],
        color: 'Default',
        icon: CupertinoIcons.list_bullet,
      );

      newTaskList = const TaskListModel(
        id: '2',
        name: 'New TaskList',
        tasks: [],
        color: 'Default',
        icon: CupertinoIcons.list_bullet,
      );

      updatedTaskList = const TaskListModel(
        id: '3',
        name: 'Updated TaskList',
        tasks: [],
        color: 'Default',
        icon: CupertinoIcons.list_bullet,
      );

      taskListModelList = [taskList];
    });

    test('initial state is TaskListInitial', () {
      expect(taskListBloc.state, TaskListInitial());
    });

    group('LoadTaskLists', () {
      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListLoaded] when task lists are loaded successfully',
        build: () {
          when(mockBox.values).thenReturn(taskListModelList);
          return taskListBloc;
        },
        act: (bloc) => bloc.add(LoadTaskLists()),
        expect: () => [
          TaskListLoading(),
          TaskListLoaded([taskList]),
        ],
      );

      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListEmpty] when no task lists are present',
        build: () {
          when(mockBox.values).thenReturn([]);
          return taskListBloc;
        },
        act: (bloc) => bloc.add(LoadTaskLists()),
        expect: () => [
          TaskListLoading(),
          const TaskListEmpty(message: 'You do not have any Task List'),
        ],
      );

      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListError] when loading task lists fails',
        build: () {
          when(mockBox.values)
              .thenThrow(Exception('Failed to load task lists'));
          return taskListBloc;
        },
        act: (bloc) => bloc.add(LoadTaskLists()),
        expect: () => [
          TaskListLoading(),
          const TaskListError('Failed to load task lists'),
        ],
      );
    });

    group('AddTaskList', () {
      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListLoaded] when adding a task list is successful',
        build: () {
          when(mockBox.put(any, newTaskList)).thenAnswer((_) async {
            taskListModelList.add(newTaskList);
          });
          when(mockBox.values).thenReturn(taskListModelList);
          return taskListBloc;
        },
        act: (bloc) => bloc.add(AddTaskList(newTaskList)),
        expect: () => [
          TaskListLoaded(taskListModelList),
        ],
      );

      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListError] when adding a task list fails',
        build: () {
          when(mockBox.put(any, taskList))
              .thenThrow(Exception('Failed to add task list'));
          return taskListBloc;
        },
        act: (bloc) => bloc.add(AddTaskList(taskList)),
        expect: () => [
          const TaskListError('Failed to add task list'),
        ],
      );
    });

    group('UpdateTaskList', () {
      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListLoaded] when updating a task list is successful',
        build: () {
          when(mockBox.put(taskList.id, updatedTaskList)).thenAnswer((_) async {
            taskListModelList.remove(taskList);
            taskListModelList.add(updatedTaskList);
          });
          when(mockBox.values).thenReturn([updatedTaskList]);
          return taskListBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskList(updatedTaskList)),
        expect: () => [
          TaskListLoaded([updatedTaskList]),
        ],
      );

      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListError] when updating a task list fails',
        build: () {
          when(mockBox.put(any, any))
              .thenThrow(Exception('Failed to update task list'));
          return taskListBloc;
        },
        act: (bloc) => bloc.add(UpdateTaskList(taskList)),
        expect: () => [
          const TaskListError('Failed to update task list'),
        ],
      );
    });

    group('DeleteTaskList', () {
      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListLoaded] when deleting a task list is successful',
        build: () {
          when(mockBox.delete(taskList)).thenAnswer((_) async {
            taskListModelList.remove(taskList);
          });
          when(mockBox.values).thenReturn([]);
          return taskListBloc;
        },
        act: (bloc) => bloc.add(DeleteTaskList(taskList.id)),
        expect: () => [
          const TaskListLoaded([]),
        ],
      );

      blocTest<TaskListBloc, TaskListState>(
        'emits [TaskListLoading, TaskListError] when deleting a task list fails',
        build: () {
          when(mockBox.delete(any))
              .thenThrow(Exception('Failed to delete task list'));
          return taskListBloc;
        },
        act: (bloc) => bloc.add(DeleteTaskList(taskList.id)),
        expect: () => [
          const TaskListError('Failed to delete task list'),
        ],
      );
    });
  });
}
