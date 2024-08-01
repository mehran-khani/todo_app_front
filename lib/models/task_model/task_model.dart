import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;
// 'completed', 'incomplete', etc.
  @HiveField(3)
  final String status;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final List<dynamic> tags;

  @HiveField(6)
  final bool isFlagged;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    this.tags = const [],
    this.isFlagged = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    List<dynamic>? tags,
    bool? isFlagged,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

// These methods are used for converting the TaskModel to and from a map representation.
// This is useful for potential future integration with remote databases or APIs,
// such as Firestore, where data needs to be serialized and deserialized as maps.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'tags': tags,
      'isFlagged': isFlagged,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      dueDate: DateTime.parse(map['dueDate']),
      tags: List<dynamic>.from(map['tags']),
      isFlagged: map['isFlagged'] ?? false,
    );
  }
/////////////////////////////////////////////////////////////
  @override
  List<Object> get props => [
        id,
        title,
        description,
        status,
        dueDate,
        tags,
        isFlagged,
      ];

  @override
  bool? get stringify => true;
}
