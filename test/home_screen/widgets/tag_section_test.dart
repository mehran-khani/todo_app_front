import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/screens/home_screen_widget/tag_section.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';

import 'custom_task_list_section_test.mocks.dart';

void main() {
  group('TagSection Tests', () {
    late MockBoxTagModel mockBoxTagModel;
    late TagBloc tagBloc;
    late List<TagModel> tags;

    setUp(() {
      mockBoxTagModel = MockBoxTagModel();
      tagBloc = TagBloc(mockBoxTagModel);

      // Test data
      tags = [
        const TagModel(id: '1', name: 'Work'),
        const TagModel(id: '2', name: 'Personal'),
        const TagModel(id: '3', name: 'Urgent'),
      ];
    });

    testWidgets('displays loading indicator when state is TagLoading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: tagBloc..emit(TagLoading()),
            child: const TagSection(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays tags when state is TagLoaded',
        (WidgetTester tester) async {
      tagBloc.emit(TagLoaded(tags));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: tagBloc,
            child: const Scaffold(
              body: TagSection(),
            ),
          ),
        ),
      );

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('displays error message when state is TagError',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: tagBloc..emit(const TagError('Failed to load tags')),
            child: const Scaffold(
              body: TagSection(),
            ),
          ),
        ),
      );

      expect(find.text('Failed to load tags'), findsOneWidget);
    });

    testWidgets('displays empty message when state is TagEmpty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: tagBloc..emit(const TagEmpty(message: 'No tags available')),
            child: const Scaffold(
              body: TagSection(),
            ),
          ),
        ),
      );

      expect(find.text('No tags available'), findsOneWidget);
    });

    testWidgets('displays tags as ActionChip when state is TagLoaded',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: tagBloc..emit(TagLoaded(tags)),
            child: const Scaffold(
              body: TagSection(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ActionChip), findsNWidgets(tags.length));
      for (var tag in tags) {
        expect(find.text(tag.name), findsOneWidget);
      }
    });
  });
}
