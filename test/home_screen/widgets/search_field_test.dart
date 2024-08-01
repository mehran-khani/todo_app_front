import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/screens/home_screen_widget/search_field.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

import 'widgets_test.mocks.dart';

void main() {
  group('SearchField', () {
    late TaskBloc taskBloc;
    late MockBoxTaskModel mockBox;

    setUp(() {
      mockBox = MockBoxTaskModel();
      taskBloc = TaskBloc(mockBox);
    });

    testWidgets('renders with correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: taskBloc,
            child: const Scaffold(
              body: SearchField(),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (textField.decoration as InputDecoration).hintText,
        'Search',
      );
      expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    });
  });
}
