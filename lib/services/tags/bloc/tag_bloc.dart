import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:to_do_application/models/tag_model.dart/tag_model.dart';

part 'tag_event.dart';
part 'tag_state.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final Box<TagModel> tagBox;

  TagBloc(this.tagBox) : super(TagInitial()) {
    on<LoadTags>(_onLoadTags);
    on<AddTag>(_onAddTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
  }

  void _onLoadTags(LoadTags event, Emitter<TagState> emit) {
    emit(TagLoading());
    try {
      final tags = tagBox.values.toList();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(const TagError("Failed to load tags"));
    }
  }

  void _onAddTag(AddTag event, Emitter<TagState> emit) {
    try {
      tagBox.put(event.tag.id, event.tag);
      final tags = tagBox.values.toList();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(const TagError("Failed to add tag"));
    }
  }

  void _onUpdateTag(UpdateTag event, Emitter<TagState> emit) {
    try {
      tagBox.put(event.tag.id, event.tag);
      final tags = tagBox.values.toList();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(const TagError("Failed to update tag"));
    }
  }

  void _onDeleteTag(DeleteTag event, Emitter<TagState> emit) {
    try {
      tagBox.delete(event.id);
      final tags = tagBox.values.toList();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(const TagError("Failed to delete tag"));
    }
  }
}
