import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class SearchForBookmarks extends StatefulWidget {
  const SearchForBookmarks({super.key, required this.bookmarks});
  final List<NoteModel> bookmarks;

  @override
  State<SearchForBookmarks> createState() => _SearchForBookmarksState();
}

class _SearchForBookmarksState extends State<SearchForBookmarks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for bookmarks'),
      ),
    );
  }
}
