import 'package:hive/hive.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 1)
class TagModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  TagModel({required this.id, required this.name});

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
}
