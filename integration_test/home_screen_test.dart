import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/screens/home_screen.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_list_modal.dart';
import 'package:to_do_application/screens/home_screen_widget/create_task_modal.dart';
import 'package:to_do_application/screens/home_screen_widget/custom_task_list_section.dart';
import 'package:to_do_application/screens/home_screen_widget/search_field.dart';
import 'package:to_do_application/screens/home_screen_widget/tag_section.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/services/authentication/cubit/authentication_cubit.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskListModelAdapter());
  Hive.registerAdapter(TagModelAdapter());

  final taskBox = await Hive.openBox<TaskModel>('tasks');
  final taskListBox = await Hive.openBox<TaskListModel>('taskLists');
  final tagBox = await Hive.openBox<TagModel>('tags');

  testWidgets('Home Screen integration test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationCubit>(
            create: (context) => AuthenticationCubit(),
          ),
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc(taskBox),
          ),
          BlocProvider<TaskListBloc>(
            create: (context) => TaskListBloc(taskListBox),
          ),
          BlocProvider<TagBloc>(
            create: (context) => TagBloc(tagBox),
          ),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for the app to build and display the Home Screen
    await tester.pumpAndSettle();

    // Add test expectations here
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SearchField), findsOneWidget);
    expect(find.byType(TaskSummaryList), findsOneWidget);
    expect(find.byType(CustomTaskListSection), findsOneWidget);
    expect(find.byType(TagSection), findsOneWidget);

    // Check for presence of TextButton widgets in the BottomAppBar
    expect(find.widgetWithText(TextButton, 'New Task'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Add List'), findsOneWidget);

    // Optionally check if the AppBar contains an IconButton
    expect(find.byType(IconButton), findsOneWidget);

    // Check if SearchField contains a TextField with the placeholder text 'Search'
    expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField && widget.decoration!.hintText == 'Search'),
        findsOneWidget);

    // Simulate tapping on 'New Task' button to show CreateTaskModal
    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateTaskModal), findsOneWidget);

    // Close the CreateTaskModal
    await tester.tap(find.byIcon(CupertinoIcons.multiply));
    await tester.pumpAndSettle();

    // Simulate tapping on 'Add List' button to show CreateTaskListModal
    await tester.tap(find.text('Add List'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateTaskListModal), findsOneWidget);

    // Close the CreateTaskListModal
    await tester.tap(find.byIcon(CupertinoIcons.multiply));
    await tester.pumpAndSettle();

    // Verify that the scroll behavior works as expected
    final scrollable = find.byType(SingleChildScrollView);
    expect(scrollable, findsOneWidget);
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify that TaskSummaryList contains a GridView
    expect(find.byType(GridView), findsOneWidget);
  });
}
