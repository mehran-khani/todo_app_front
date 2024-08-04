import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_application/helpers/color_utils.dart';
import 'package:to_do_application/helpers/icon_utils.dart';
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
  TaskListColor _selectedColor = TaskListColor.defaultColor;
  TaskListIcon _selectedIcon = TaskListIcon.listBullet;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    // creating a new task list
                    if (_nameController.text.isNotEmpty) {
                      context.read<TaskListBloc>().add(
                            AddTaskList(
                              TaskListModel(
                                id: const Uuid().v4(),
                                name: _nameController.text.trim(),
                                tasks: const [],
                                color: _selectedColor.name,
                                icon: _selectedIcon.name,
                              ),
                            ),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedColor.color,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(140, 33, 149, 243),
                            spreadRadius: 1,
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        _selectedIcon.iconData,
                        color: Colors.white,
                        size: 78,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'List Name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                children: TaskListColor.values.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                children: TaskListIcon.values.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: _selectedIcon == icon
                                  ? _selectedColor.color
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedIcon == icon
                                ? _selectedColor.color
                                : Colors.grey.shade400,
                          ),
                          child: Icon(
                            icon.iconData,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
