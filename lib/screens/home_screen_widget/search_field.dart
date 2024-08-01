import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(height: 1.30),
          filled: true,
          fillColor: Colors.black.withOpacity(0.045),
          prefixIcon: const Icon(CupertinoIcons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        cursorColor: Colors.blue,
        onChanged: (value) {
          context.read<TaskBloc>().add(SearchTasks(value));
        },
      ),
    );
  }
}
