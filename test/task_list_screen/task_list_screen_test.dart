import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/screens/home_screen_widget/task_list_widget.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/screens/task_list_screen.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

import '../home_screen/widgets/custom_task_list_section_test.mocks.dart';

void main() {
  late TaskBloc taskBloc;
  late TagBloc tagBloc;
  late MockBoxTaskModel taskBox;
  late MockBoxTagModel tagBox;

  setUp(() {
    taskBox = MockBoxTaskModel();
    tagBox = MockBoxTagModel();
    taskBloc = TaskBloc(taskBox);
    tagBloc = TagBloc(tagBox);
  });

  tearDown(() {
    taskBloc.close();
    tagBloc.close();
  });

  testWidgets('displays loading indicator while tasks are loading',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc..emit(TaskLoading()),
          child: const TaskListScreen(category: TaskCategory.today),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays empty message when there are no tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc..emit(const TaskEmpty(message: 'No tasks available')),
          child: const TaskListScreen(category: TaskCategory.today),
        ),
      ),
    );

    expect(find.text('No tasks available'), findsOneWidget);
  });

  testWidgets('displays tasks based on category when no tag is provided',
      (WidgetTester tester) async {
    final tasks = [
      TaskModel(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        status: 'incomplete',
        dueDate: DateTime.now(),
        tags: const ['Tag1'],
        isFlagged: false,
      )
    ];
    when(taskBox.values).thenReturn(tasks);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc..emit(TaskLoaded(tasks)),
          child: const TaskListScreen(category: TaskCategory.today),
        ),
      ),
    );

    expect(find.byType(TaskListWidget), findsOneWidget);
    expect(find.text('Task 1'), findsOneWidget);
  });

  testWidgets('displays tasks filtered by tag', (WidgetTester tester) async {
    final tasks = [
      TaskModel(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        status: 'incomplete',
        dueDate: DateTime.now(),
        tags: const ['Tag1'],
        isFlagged: false,
      )
    ];
    when(taskBox.values).thenReturn(tasks);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc..emit(TaskLoaded(tasks)),
          child: const TaskListScreen(
            category: TaskCategory.all,
            tag: 'Tag1',
          ),
        ),
      ),
    );

    expect(find.byType(TaskListWidget), findsOneWidget);
    expect(find.text('Task 1'), findsOneWidget);
  });

  testWidgets('displays error message when there is a TaskError',
      (WidgetTester tester) async {
    when(taskBox.values).thenReturn([]);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc..emit(const TaskError('Error occurred')),
          child: const TaskListScreen(category: TaskCategory.today),
        ),
      ),
    );
    expect(find.text('Error occurred'), findsOneWidget);
  });
}
