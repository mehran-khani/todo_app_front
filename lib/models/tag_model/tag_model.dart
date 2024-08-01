import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 1)
class TagModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  const TagModel({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  List<Object> get props => [id, name];

  @override
  bool? get stringify => true;
}
