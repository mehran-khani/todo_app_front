import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_list_modal.dart';

import 'custom_task_list_section_test.mocks.dart';

// Mock Data
const TaskListModel mockTaskList = TaskListModel(
  id: '1',
  name: 'Test Task List',
  tasks: [],
  color: 'Default',
  icon: CupertinoIcons.list_bullet,
);

void main() {
  late TaskListBloc taskListBloc;
  late MockBoxTaskListModel taskListBox;

  setUp(() {
    taskListBox = MockBoxTaskListModel();
    taskListBloc = TaskListBloc(taskListBox);

    when(taskListBox.values).thenReturn([mockTaskList]);
  });

  testWidgets('renders CreateTaskListModal with all fields and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskListBloc>.value(
            value: taskListBloc,
            child: const CreateTaskListModal(),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget); // List Name
    expect(
        find.byType(DropdownButton<String>), findsOneWidget); // Theme Dropdown
    // expect( find.byType(IconButton), findsNWidgets(4)); // Close, Done, and the count of the Icons
    expect(find.text('Create New List'), findsOneWidget);
    expect(find.text('Select Theme'), findsOneWidget);
    expect(find.text('Select Icon'), findsOneWidget);
  });

  testWidgets('allows user to input data into the list name field',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskListBloc>.value(
            value: taskListBloc,
            child: const CreateTaskListModal(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'New List Name');

    expect(find.text('New List Name'), findsOneWidget);
  });

  testWidgets('allows user to select a theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskListBloc>.value(
            value: taskListBloc,
            child: const CreateTaskListModal(),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();

    // Select 'Dark' theme.
    //TODO: themes should be refined and chagne to a list of colors
    await tester.tap(find.text('Dark').last);
    await tester.pump();

    // Verify the selected theme
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('submits task list with name, theme, and icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskListBloc>.value(
            value: taskListBloc,
            child: const CreateTaskListModal(),
          ),
        ),
      ),
    );

    // Input data
    await tester.enterText(find.byType(TextField), 'New Task List');
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();

    // Select 'Dark' theme
    await tester.tap(find.text('Dark').last);
    await tester.pump();

    // Select the work icon
    await tester.tap(find.byIcon(CupertinoIcons.bag_fill));
    await tester.pump();

    // Submit
    await tester.tap(find.byIcon(CupertinoIcons.check_mark));
    await tester.pumpAndSettle();

    // Verify the task list bloc state
    final taskListState = taskListBloc.state;
    expect(taskListState, isA<TaskListLoaded>());

    expect(
      taskListBloc.state,
      isA<TaskListLoaded>().having(
        (state) => state.taskLists,
        'tasks',
        contains(mockTaskList),
      ),
    );
  });

  testWidgets('allows user to select an icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskListBloc>.value(
            value: taskListBloc,
            child: const CreateTaskListModal(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(CupertinoIcons.bag_fill));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.bag_fill), findsOneWidget);
  });
}
