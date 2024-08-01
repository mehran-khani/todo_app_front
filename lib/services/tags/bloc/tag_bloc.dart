import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:to_do_application/models/tag_model/tag_model.dart';

part 'tag_event.dart';
part 'tag_state.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final Box<TagModel> tagBox;

  TagBloc(this.tagBox) : super(TagInitial()) {
    on<LoadTags>(_onLoadTags);
    on<AddTag>(_onAddTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);

    add(LoadTags());
  }

  void _onLoadTags(LoadTags event, Emitter<TagState> emit) {
    emit(TagLoading());
    try {
      final tags = tagBox.values.toList();
      if (tags.isEmpty) {
        emit(
          const TagEmpty(message: 'You do not have any Tag'),
        );
      } else {
        // Sort tags alphabetically by name
        tags.sort((a, b) => a.name.compareTo(b.name));
        emit(TagLoaded(tags));
      }
    } catch (e) {
      emit(const TagError("Failed to load tags"));
    }
  }

  void _onAddTag(AddTag event, Emitter<TagState> emit) {
    try {
      // Retrieve existing tag names from the box
      final existingTags =
          tagBox.values.map((tagModel) => tagModel.name).toSet();

      for (var tag in event.tags) {
        // Check if the tag already exists by name
        if (!existingTags.contains(tag)) {
          // Generate a unique ID for each tag
          final id = UniqueKey().toString();
          // Convert the string to a TagModel instance
          final tagModel = TagModel(id: id, name: tag);
          tagBox.put(id, tagModel);
          existingTags.add(tag); // Update the existingTags set
        }
      }

      // Retrieve updated tags
      final tags = tagBox.values.toList();
      tags.sort((a, b) => a.name.compareTo(b.name));
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
