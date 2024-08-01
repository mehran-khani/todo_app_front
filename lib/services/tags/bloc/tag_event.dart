part of 'tag_bloc.dart';

sealed class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => true;
}

class LoadTags extends TagEvent {}

class AddTag extends TagEvent {
  final List<String> tags;

  const AddTag(this.tags);

  @override
  List<Object> get props => [tags];
}

class UpdateTag extends TagEvent {
  final TagModel tag;

  const UpdateTag(this.tag);

  @override
  List<Object> get props => [tag];
}

class DeleteTag extends TagEvent {
  final String id;

  const DeleteTag(this.id);

  @override
  List<Object> get props => [id];
}
