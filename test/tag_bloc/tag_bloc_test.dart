import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';

import 'tag_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Box<TagModel>>()])
void main() {
  group('TagBloc', () {
    late TagBloc tagBloc;
    late MockBox mockTagBox;
    late TagModel testTag;

    setUp(() {
      mockTagBox = MockBox();
      tagBloc = TagBloc(mockTagBox);

      testTag = const TagModel(
        id: '1',
        name: 'Test Tag',
      );
    });

    test('initial state is TagInitial', () {
      expect(tagBloc.state, TagInitial());
    });

    group('LoadTags', () {
      blocTest<TagBloc, TagState>(
        'emits [TagLoading, TagLoaded] when tags are loaded successfully',
        build: () {
          when(mockTagBox.values).thenReturn([testTag]);
          return tagBloc;
        },
        act: (bloc) => bloc.add(LoadTags()),
        expect: () => [
          TagLoading(),
          TagLoaded([testTag]),
        ],
      );

      blocTest<TagBloc, TagState>(
        'emits [TagLoading, TagError] when tags loading fails',
        build: () {
          when(mockTagBox.values).thenThrow(Exception('Failed to load tags'));
          return tagBloc;
        },
        act: (bloc) => bloc.add(LoadTags()),
        expect: () => [
          TagLoading(),
          const TagError("Failed to load tags"),
        ],
      );
    });

    group('AddTag', () {
      blocTest<TagBloc, TagState>(
        'emits [TagLoaded] when tags are added successfully',
        build: () {
          // Mock the box to initially return a list of tags
          when(mockTagBox.values).thenReturn([testTag]);
          // Mock put method to succeed
          when(mockTagBox.put(any, any)).thenAnswer((_) async {});
          return tagBloc;
        },
        act: (bloc) {
          bloc.add(const AddTag(['New Tag']));
        },
        expect: () async {
          verify(mockTagBox.put(any, argThat(isA<TagModel>()))).called(1);
          return [
            TagLoaded([testTag]),
          ];
        },
      );
      blocTest<TagBloc, TagState>(
        'emits [TagError] when adding tags fails',
        build: () {
          when(mockTagBox.put(any, any))
              .thenThrow(Exception('Failed to add tag'));
          return tagBloc;
        },
        act: (bloc) => bloc.add(const AddTag(['New Tag'])),
        expect: () => [
          const TagError("Failed to add tag"),
        ],
      );
    });

    group('UpdateTag', () {
      blocTest<TagBloc, TagState>(
        'emits [TagLoaded] when a tag is updated successfully',
        build: () {
          when(mockTagBox.put(any, any)).thenAnswer((_) async {});
          when(mockTagBox.values).thenReturn([testTag]);
          return tagBloc;
        },
        act: (bloc) => bloc.add(UpdateTag(testTag)),
        expect: () => [
          TagLoaded([testTag]),
        ],
      );

      blocTest<TagBloc, TagState>(
        'emits [TagError] when updating a tag fails',
        build: () {
          when(mockTagBox.put(any, any))
              .thenThrow(Exception('Failed to update tag'));
          return tagBloc;
        },
        act: (bloc) => bloc.add(UpdateTag(testTag)),
        expect: () => [
          const TagError("Failed to update tag"),
        ],
      );
    });

    group('DeleteTag', () {
      blocTest<TagBloc, TagState>(
        'emits [TagLoaded] when a tag is deleted successfully',
        build: () {
          when(mockTagBox.delete(any)).thenAnswer((_) async {});
          when(mockTagBox.values).thenReturn([]);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const DeleteTag('1')),
        expect: () => [
          const TagLoaded([]),
        ],
      );

      blocTest<TagBloc, TagState>(
        'emits [TagError] when deleting a tag fails',
        build: () {
          when(mockTagBox.delete(any))
              .thenThrow(Exception('Failed to delete tag'));
          return tagBloc;
        },
        act: (bloc) => bloc.add(const DeleteTag('1')),
        expect: () => [
          const TagError("Failed to delete tag"),
        ],
      );
    });

    blocTest<TagBloc, TagState>(
      'emits [TagLoading, TagLoaded([])] when no tags are present',
      build: () {
        when(mockTagBox.values).thenReturn([testTag]);
        return tagBloc;
      },
      act: (bloc) => bloc.add(LoadTags()),
      expect: () => [
        TagLoading(),
        TagLoaded([testTag]),
      ],
    );

    blocTest<TagBloc, TagState>(
      'emits [TagLoading, TagEmpty] when no tags are present',
      build: () {
        when(mockTagBox.values).thenReturn([]);
        return tagBloc;
      },
      act: (bloc) => bloc.add(LoadTags()),
      expect: () => [
        TagLoading(),
        const TagEmpty(message: 'You do not have any Tag'),
      ],
    );

    blocTest<TagBloc, TagState>(
      'emits [TagError] when an unexpected error occurs during tag addition',
      build: () {
        when(mockTagBox.put(any, any)).thenThrow(Exception('Unexpected error'));
        return tagBloc;
      },
      act: (bloc) => bloc.add(const AddTag(['New Tag'])),
      expect: () => [
        const TagError("Failed to add tag"),
      ],
    );
  });
}
