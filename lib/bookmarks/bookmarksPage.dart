import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<NoteModel> bookmarkedNotes = [];

  void fetchBookmarks() async {
    final directory = await getApplicationDocumentsDirectory();
    final noteFiles = directory.listSync().where((file) => file.path.endsWith('.json'));
    List<NoteModel> loadedNotes = [];
    for (var file in noteFiles){
      final noteContent = await File(file.path).readAsString();
      final noteJson = jsonDecode(noteContent);
      loadedNotes.add(NoteModel.fromJson(noteJson));
    }
  }

  @override
  void initState() {
    fetchBookmarks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks'), actions: <Widget>[
      IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      IconButton(
          onPressed: () {},
          icon: const Icon(Icons.delete_forever, color: Colors.tealAccent))
    ]));
  }
}
