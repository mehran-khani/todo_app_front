import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_modal.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

import 'custom_task_list_section_test.mocks.dart';

// Mock Data
final List<TagModel> mockTags = [
  const TagModel(id: '1', name: 'Tag1'),
  const TagModel(id: '2', name: 'Tag2'),
];

const TagModel mockTag = TagModel(id: '3', name: 'Tag3');

final List<TaskModel> mockTasks = [
  TaskModel(
    id: '1',
    title: 'Test Task 1',
    description: 'This is a test task 1.',
    status: 'incomplete',
    dueDate: DateTime.now(),
    tags: const ['Tag1'],
    isFlagged: false,
  )
];

final TaskModel mockTask = TaskModel(
  id: '2',
  title: 'Test Task 2',
  description: 'This is a test task 2.',
  status: 'incomplete',
  dueDate: DateTime.now(),
  tags: const ['Tag2'],
  isFlagged: false,
);

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

    // Setup mock responses
    when(tagBox.values).thenReturn(mockTags);
    when(taskBox.values).thenReturn([mockTask]);
  });

  testWidgets('renders CreateTaskModal with all fields and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TagBloc>.value(
            value: tagBloc,
            child: BlocProvider<TaskBloc>.value(
              value: taskBloc,
              child: const CreateTaskModal(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField),
        findsNWidgets(3)); // Title and Description and tag
    expect(find.byType(TextFieldTags<String>), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(3)); // Close, Done, Calendar
    expect(find.text('New Reminder'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
  });

  testWidgets('allows user to input data into title and description fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TagBloc>.value(
            value: tagBloc,
            child: BlocProvider<TaskBloc>.value(
              value: taskBloc,
              child: const CreateTaskModal(),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Task Title');
    await tester.enterText(find.byType(TextField).at(1), 'Task Description');

    expect(find.text('Task Title'), findsOneWidget);
    expect(find.text('Task Description'), findsOneWidget);
  });

  testWidgets('manages tags correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TagBloc>.value(
            value: tagBloc,
            child: BlocProvider<TaskBloc>.value(
              value: taskBloc,
              child: const CreateTaskModal(),
            ),
          ),
        ),
      ),
    );

    // Enter a tag
    await tester.enterText(find.byType(TextFieldTags<String>), 'Tag1');
    await tester.pump();

    // Verify that the tag appears
    expect(find.text('Tag1'), findsOneWidget);
  });

  testWidgets('selects a due date correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TagBloc>.value(
            value: tagBloc,
            child: BlocProvider<TaskBloc>.value(
              value: taskBloc,
              child: const CreateTaskModal(),
            ),
          ),
        ),
      ),
    );

    // Open the date picker
    await tester.tap(find.byIcon(CupertinoIcons.calendar));
    await tester.pump();

    // Select a date
    await tester.tap(find.text('15').last);
    await tester.pump();

    // Close the date picker
    await tester.tap(find.text('OK'));
    await tester.pump();

    // Verify the selected date is displayed
    expect(find.text('Due on: ${DateTime.now().year}-08-15'), findsOneWidget);
  });

  testWidgets('submits task with title, description, tags, and date',
      (WidgetTester tester) async {
    when(tagBox.put(any, mockTag)).thenAnswer(
      (realInvocation) async => mockTags.add(mockTag),
    );
    when(taskBox.put(any, mockTask)).thenAnswer(
      (realInvocation) async => mockTasks.add(mockTask),
    );
    tagBloc.add(LoadTags());
    taskBloc.add(LoadTasks());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TagBloc>.value(
            value: tagBloc,
            child: BlocProvider<TaskBloc>.value(
              value: taskBloc,
              child: const CreateTaskModal(),
            ),
          ),
        ),
      ),
    );

    // Input data
    await tester.enterText(find.byType(TextField).at(0), 'Task Title');
    await tester.enterText(find.byType(TextField).at(1), 'Task Description');
    await tester.enterText(find.byType(TextFieldTags<String>), 'Tag1');

    // Open and select a date
    await tester.tap(find.byIcon(CupertinoIcons.calendar));
    await tester.pump();

    await tester.tap(find.text('15').last); // Choose a specific date
    await tester.pump();
    // Close the date picker
    await tester.tap(find.text('OK'));
    await tester.pump();

    // Submit
    await tester.tap(find.byIcon(CupertinoIcons.check_mark));
    await tester.pumpAndSettle();

    // Verify tag bloc state
    final tagState = tagBloc.state;
    expect(tagState, isA<TagLoaded>());

    final tagLoadedState = tagState as TagLoaded;

    // Verify all the tags are there
    expect(
      tagLoadedState.tags,
      containsAllInOrder(mockTags),
    );

    // Verify task bloc state
    final taskState = taskBloc.state;
    expect(taskState, isA<TaskLoaded>());

    expect(
      taskBloc.state,
      isA<TaskLoaded>().having(
        (state) => state.tasks,
        'tasks',
        contains(mockTask),
      ),
    );
  });
}
