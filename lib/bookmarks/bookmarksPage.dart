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
  bool isLoading = true;

  void fetchBookmarks() async {
    final directory = await getApplicationDocumentsDirectory();
    final noteFiles =
        directory.listSync().where((file) => file.path.endsWith('.json'));

    List<NoteModel> loadedNotes = [];
    for (var file in noteFiles) {
      final noteContent = await File(file.path).readAsString();
      final noteJson = jsonDecode(noteContent);
      final note = NoteModel.fromJson(noteJson);

      if (note.isBookmarked) {
        loadedNotes.add(note);
      }
    }
    setState(() {
      bookmarkedNotes = loadedNotes;
      isLoading = false;
    });
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
          IconButton(
              onPressed: () {Navigator.pushNamed(context, '/search_bookmarks');},
              icon: const Icon(Icons.search, color: Colors.green)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete_forever, color: Colors.green))
        ]),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : bookmarkedNotes.isEmpty
                    ? const Center(child: Text('No bookmarks'))
                    : ListView.builder(
                        itemCount: bookmarkedNotes.length,
                        itemBuilder: (context, index) {
                          NoteModel note = bookmarkedNotes[index];
                          return ListTile(
                            leading: const Icon(Icons.note),
                            title: Text(note.noteTitle),
                            trailing: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_vert)),
                            onTap: () {},
                          );
                        })));
  }
}