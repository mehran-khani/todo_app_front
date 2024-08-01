import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/screens/home_screen_widget/task_summary_list.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';

class TagSection extends StatelessWidget {
  const TagSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        BlocBuilder<TagBloc, TagState>(
          builder: (context, state) {
            if (state is TagLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TagLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: state.tags.map(
                      (tag) {
                        return ActionChip(
                          label: Text(tag.name),
                          side: BorderSide.none,
                          color: WidgetStateProperty.all(
                              Colors.black.withOpacity(0.045)),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/taskList',
                              arguments: {
                                'category': TaskCategory.all,
                                'tag': tag.name,
                              },
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                ],
              );
            } else if (state is TagError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is TagEmpty) {
              //TODO: Empty state should be handle with an animation or a better desing
              return Center(
                child: Text(state.message),
              );
            } else if (state is TagInitial) {
              context.read<TagBloc>().add(LoadTags());
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text('No tags available'),
              );
            }
          },
        ),
      ],
    );
  }
}
