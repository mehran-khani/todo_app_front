part of 'tag_bloc.dart';

sealed class TagState extends Equatable {
  const TagState();

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => true;
}

final class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<TagModel> tags;

  const TagLoaded(this.tags);

  @override
  List<Object> get props => [tags];
}

class TagError extends TagState {
  final String message;

  const TagError(this.message);

  @override
  List<Object> get props => [message];
}
