import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/screens/custom_task_list_screen.dart';
import 'package:to_do_application/screens/home_screen_widget/custom_task_list_section.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';

import 'widgets_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Box<TaskModel>>(as: #MockBoxTaskModel),
  MockSpec<Box<TaskListModel>>(as: #MockBoxTaskListModel),
  MockSpec<Box<TagModel>>(as: #MockBoxTagModel),
])

// Test data
final taskLists = [
  TaskListModel(
    id: '1',
    name: 'Task List 1',
    tasks: [
      TaskModel(
        id: 'task1',
        title: 'Task 1',
        description: 'Description for Task 1',
        status: 'incomplete',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        tags: const ['urgent'],
        isFlagged: true,
      )
    ],
    theme: 'theme1',
    icon: Icons.list,
  ),
  TaskListModel(
    id: '2',
    name: 'Task List 2',
    tasks: [
      TaskModel(
        id: 'task2',
        title: 'Task 2',
        description: 'Description for Task 2',
        status: 'completed',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        tags: const ['home'],
        isFlagged: false,
      )
    ],
    theme: 'theme2',
    icon: Icons.list_alt,
  ),
];

void main() {
  group('CustomTaskListSection Tests', () {
    late TaskListBloc taskListBloc;
    late MockBoxTaskListModel mockBox;

    setUp(() {
      mockBox = MockBoxTaskListModel();
      taskListBloc = TaskListBloc(mockBox);
    });

    testWidgets('displays loading indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: taskListBloc..emit(TaskListLoading()),
          child: const MaterialApp(
            home: Scaffold(body: CustomTaskListSection()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays task lists when loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: taskListBloc..emit(TaskListLoaded(taskLists)),
          child: const MaterialApp(
            home: Scaffold(body: CustomTaskListSection()),
          ),
        ),
      );

      expect(find.text('Task List 1'), findsOneWidget);
      expect(find.text('Task List 2'), findsOneWidget);

      await tester.tap(find.text('Task List 1'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomTaskListScreen), findsOneWidget);
    });

    testWidgets('displays error message on error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: taskListBloc
            ..emit(const TaskListError('Failed to load task lists')),
          child: const MaterialApp(
            home: Scaffold(body: CustomTaskListSection()),
          ),
        ),
      );

      expect(find.text('Failed to load task lists'), findsOneWidget);
    });

    testWidgets('displays empty state message when no task lists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: taskListBloc
            ..emit(const TaskListEmpty(message: 'No task lists available')),
          child: const MaterialApp(
            home: Scaffold(body: CustomTaskListSection()),
          ),
        ),
      );

      expect(find.text('No task lists available'), findsOneWidget);
    });
  });
}
