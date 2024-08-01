import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/models/task_list_model/task_list_model.dart';
import 'package:to_do_application/services/task_list/bloc/task_list_bloc.dart';
import 'package:uuid/uuid.dart';

class CreateTaskListModal extends StatefulWidget {
  const CreateTaskListModal({super.key});

  @override
  CreateTaskListModalState createState() => CreateTaskListModalState();
}

class CreateTaskListModalState extends State<CreateTaskListModal> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedTheme = 'Default';
  IconData _selectedIcon = CupertinoIcons.list_bullet;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.multiply),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Create New List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.check_mark),
                onPressed: () {
                  // Handle creating a new task list
                  if (_nameController.text.isNotEmpty) {
                    context.read<TaskListBloc>().add(
                          AddTaskList(
                            TaskListModel(
                              id: const Uuid().v4(),
                              name: _nameController.text.trim(),
                              tasks: const [],
                              theme: _selectedTheme,
                              icon: _selectedIcon,
                            ),
                          ),
                        );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'List Name'),
          ),
          const SizedBox(height: 16.0),
          const Text('Select Theme'),
          DropdownButton<String>(
            value: _selectedTheme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTheme = newValue!;
              });
            },
            items: <String>['Default', 'Dark', 'Light']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          const Text('Select Icon'),
          Wrap(
            spacing: 8.0,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.list_bullet),
                onPressed: () {
                  setState(() {
                    _selectedIcon = CupertinoIcons.list_bullet;
                  });
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.bag_fill),
                onPressed: () {
                  setState(() {
                    _selectedIcon = CupertinoIcons.bag_fill;
                  });
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.cart_fill),
                onPressed: () {
                  setState(() {
                    _selectedIcon = CupertinoIcons.cart_fill;
                  });
                },
              ),
              //TODO: Add more icons
            ],
          ),
        ],
      ),
    );
  }
}
