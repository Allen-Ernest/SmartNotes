import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<NoteModel> bookmarkedNotes = [];
  void fetchBookmarks() async {}

  @override
  void initState() {
    fetchBookmarks();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks'), actions: <Widget>[
      IconButton(
          onPressed: () {}, icon: const Icon(Icons.delete_forever, color: Colors.red))
    ]));
  }
}
