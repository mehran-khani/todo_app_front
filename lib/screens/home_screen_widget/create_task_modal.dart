import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:to_do_application/models/task_model/task_model.dart';
import 'package:to_do_application/services/tags/bloc/tag_bloc.dart';
import 'package:to_do_application/services/tasks/bloc/task_bloc.dart';
import 'package:uuid/uuid.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({super.key});

  @override
  CreateTaskModalState createState() => CreateTaskModalState();
}

class CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late StringTagController _tagsController;
  DateTime? _selectedDate;

  static const List<String> _initialTags = <String>[];

  @override
  void initState() {
    super.initState();
    _tagsController = StringTagController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'New Reminder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.check_mark),
                  onPressed: () {
                    final tags = _tagsController.getTags;

                    if (_titleController.text.isNotEmpty) {
                      context.read<TagBloc>().add(AddTag(tags ?? []));
                      context.read<TaskBloc>().add(
                            AddTask(
                              TaskModel(
                                id: const Uuid().v4(),
                                title: _titleController.text.trim(),
                                description: _descriptionController.text.trim(),
                                status: 'incomplete',
                                dueDate: _selectedDate ?? DateTime.now(),
                                tags: tags ?? [],
                                isFlagged: false,
                              ),
                            ),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 48.0),
                            ),
                            maxLines: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFieldTags<String>(
                      key: const Key('tags_field'),
                      textfieldTagsController: _tagsController,
                      initialTags: _initialTags,
                      textSeparators: const [' ', ','],
                      letterCase: LetterCase.normal,
                      validator: (String tag) {
                        if (_tagsController.getTags!.contains(tag)) {
                          return 'You\'ve already entered that';
                        }
                        return null;
                      },
                      inputFieldBuilder: (context, inputFieldValues) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onTap: () {
                              _tagsController.getFocusNode?.requestFocus();
                            },
                            controller: inputFieldValues.textEditingController,
                            focusNode: inputFieldValues.focusNode,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18.0),
                              hintText: inputFieldValues.tags.isNotEmpty
                                  ? ''
                                  : "Enter tag...",
                              errorText: inputFieldValues.error,
                              prefixIconConstraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8),
                              prefixIcon: inputFieldValues.tags.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller:
                                          inputFieldValues.tagScrollController,
                                      scrollDirection: Axis.vertical,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 8,
                                          left: 8,
                                        ),
                                        child: Wrap(
                                          runSpacing: 4.0,
                                          spacing: 4.0,
                                          children: inputFieldValues.tags.map(
                                            (String tag) {
                                              return Container(
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20.0),
                                                    ),
                                                    color: Color.fromARGB(
                                                        255, 77, 137, 94)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      child: Text(
                                                        '#$tag',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        //print("$tag selected");
                                                      },
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    InkWell(
                                                      child: const Icon(
                                                        CupertinoIcons.multiply,
                                                        size: 14.0,
                                                        color: Color.fromARGB(
                                                            255, 222, 219, 219),
                                                      ),
                                                      onTap: () {
                                                        inputFieldValues
                                                            .onTagRemoved(tag);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: inputFieldValues.onTagChanged,
                            onSubmitted: inputFieldValues.onTagSubmitted,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    InkWell(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null &&
                            selectedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(_selectedDate != null
                                ? 'Due on: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                                : 'No date selected'),
                            const SizedBox(
                              width: 12,
                            ),
                            const Icon(CupertinoIcons.calendar),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
