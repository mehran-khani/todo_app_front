import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/helpers/date_time_extensions.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/screens/task_list_screen.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

import 'widgets_test.mocks.dart';

void main() {
  late TaskBloc taskBloc;
  late MockBoxTaskModel mockBox;
  late TaskModel task1;
  late TaskModel task2;
  late List<TaskModel> tasks;

  setUpAll(() {
    mockBox = MockBoxTaskModel();
    taskBloc = TaskBloc(mockBox);

    task1 = TaskModel(
      id: '1',
      title: 'Task 1',
      description: 'this is Task 1',
      dueDate: DateTime.now(),
      status: 'complete',
      isFlagged: false,
    );
    task2 = TaskModel(
      id: '2',
      title: 'Task 2',
      description: 'this is Task 2',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'incomplete',
      isFlagged: true,
    );

    tasks = [task1, task2];
  });

  group('TaskSummaryList', () {
    testWidgets('renders TaskSummaryList with TaskSummaryItem widgets',
        (WidgetTester tester) async {
      // Mock setup
      when(mockBox.values).thenReturn(tasks);
      taskBloc.add(LoadTasks());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: taskBloc,
            child: const Scaffold(
              body: TaskSummaryList(),
            ),
          ),
        ),
      );

      // Check if the GridView is present
      expect(find.byType(GridView), findsOneWidget);

      // Check the number of items in the GridView
      expect(find.byType(TaskSummaryItem),
          findsNWidgets(TaskCategory.values.length));

      for (final category in TaskCategory.values) {
        final taskSummaryItemFinder = find.byWidgetPredicate(
          (widget) => widget is TaskSummaryItem && widget.category == category,
        );

        // Check if the TaskSummaryItem widget for the category is found
        expect(taskSummaryItemFinder, findsOneWidget);

        // Check the properties of the TaskSummaryItem
        final taskSummaryItemWidget =
            tester.widget<TaskSummaryItem>(taskSummaryItemFinder);
        final expectedColor = _getColor(category);
        final expectedIcon = _getIcon(category);
        final expectedTaskCount = _getTaskCount(category, tasks);

        // Check icon and color
        expect(
          taskSummaryItemWidget.icon,
          expectedIcon,
        );
        expect(
          taskSummaryItemWidget.color,
          expectedColor,
        );

        // Check task count within TaskSummaryItem
        final taskSummaryItemTextFinder = find.descendant(
          of: taskSummaryItemFinder,
          matching: find.text('$expectedTaskCount'),
        );
        expect(taskSummaryItemTextFinder, findsOneWidget);
      }
    });

    testWidgets('renders GridView with correct number of items and spacing',
        (WidgetTester tester) async {
      when(mockBox.values).thenReturn(tasks);
      taskBloc.add(LoadTasks());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: taskBloc,
            child: const Scaffold(
              body: TaskSummaryList(),
            ),
          ),
        ),
      );

      // Check GridView layout
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount,
          isTrue);

      // Check crossAxisCount
      final gridDelegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, 2);

      // Check spacing
      expect(gridDelegate.crossAxisSpacing, 8.0);
      expect(gridDelegate.mainAxisSpacing, 8.0);
    });
  });

  group('TaskSummaryItem', () {
    testWidgets('renders with correct icon, color, and task count',
        (WidgetTester tester) async {
      when(mockBox.values).thenReturn(tasks);
      taskBloc.add(LoadTasks());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: taskBloc,
            child: const Scaffold(
              body: TaskSummaryList(),
            ),
          ),
        ),
      );

      for (final category in TaskCategory.values) {
        final color = _getColor(category);
        final icon = _getIcon(category);
        final taskCount = _getTaskCount(category, tasks);

        // Check color
        final colorFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == color,
        );
        expect(colorFinder, findsOneWidget);

        // Check icon
        final iconFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == icon &&
              widget.color == Colors.white,
        );
        expect(iconFinder, findsOneWidget);

        // Check task count
        // Find the TaskSummaryItem widget for the category
        final taskSummaryItemFinder = find.byWidgetPredicate(
          (widget) => widget is TaskSummaryItem && widget.category == category,
        );
        final taskCountFinder = find.descendant(
          of: taskSummaryItemFinder,
          matching: find.text('$taskCount'),
        );
        expect(taskCountFinder, findsOneWidget);
      }
    });

    testWidgets('navigates to task list on tap', (WidgetTester tester) async {
      when(mockBox.values).thenReturn(tasks);
      taskBloc.add(LoadTasks());

      await tester.pumpWidget(
        BlocProvider.value(
          value: taskBloc,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: TaskCategory.values
                    .map((category) => TaskSummaryItem(category: category))
                    .toList(),
              ),
            ),
            onGenerateRoute: (settings) {
              final args = settings.arguments as Map<String, dynamic>?;

              switch (settings.name) {
                case '/taskList':
                  final category = args?['category'] as TaskCategory?;
                  final tag = args?['tag'] as String?;
                  if (category != null) {
                    return MaterialPageRoute(
                      builder: (context) => TaskListScreen(
                        category: category,
                        tag: tag,
                      ),
                    );
                  } else {
                    return MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Invalid Task List')),
                        body:
                            const Center(child: Text('Category not provided')),
                      ),
                    );
                  }
                default:
                  return MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('Page Not Found')),
                      body: const Center(child: Text('Page not found')),
                    ),
                  );
              }
            },
          ),
        ),
      );

      // Tap on the first TaskSummaryItem
      await tester.tap(find.byWidgetPredicate(
        (widget) =>
            widget is TaskSummaryItem && widget.category == TaskCategory.today,
      ));
      await tester.pumpAndSettle();

      // Define the category we are going to tap
      const tappedCategory = TaskCategory.today;
      final expectedTitle = tappedCategory.name[0].toUpperCase() +
          tappedCategory.name.substring(1);
      // Verify navigation to /taskList route
      expect(find.text(expectedTitle), findsOneWidget);
    });
  });
}

Color _getColor(TaskCategory category) {
  switch (category) {
    case TaskCategory.today:
      return Colors.blue;
    case TaskCategory.scheduled:
      return Colors.red;
    case TaskCategory.all:
      return Colors.black;
    case TaskCategory.flagged:
      return Colors.orange;
    case TaskCategory.complete:
      return Colors.green;
    default:
      return Colors.blue; // Default color
  }
}

IconData _getIcon(TaskCategory category) {
  switch (category) {
    case TaskCategory.today:
      return CupertinoIcons.sun_max;
    case TaskCategory.scheduled:
      return CupertinoIcons.calendar;
    case TaskCategory.all:
      return CupertinoIcons.tray_fill;
    case TaskCategory.flagged:
      return CupertinoIcons.flag;
    case TaskCategory.complete:
      return CupertinoIcons.check_mark;
    default:
      return CupertinoIcons.question; // Default icon
  }
}

int _getTaskCount(TaskCategory category, List<TaskModel> tasks) {
  switch (category) {
    case TaskCategory.today:
      return tasks.where((task) => task.dueDate.isToday()).length;
    case TaskCategory.scheduled:
      return tasks
          .where((task) => task.dueDate.isFuture() && task.status != 'complete')
          .length;
    case TaskCategory.flagged:
      return tasks.where((task) => task.isFlagged).length;
    case TaskCategory.complete:
      return tasks.where((task) => task.status == 'complete').length;
    case TaskCategory.all:
    default:
      return tasks.length;
  }
}
