import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:path_provider/path_provider.dart';

class NotePage extends StatefulWidget {
  final Stream<String> sortingStream;

  const NotePage({super.key, required this.sortingStream});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<NoteModel> notes = [];
  bool isLoading = true;

  Future<void> fetchNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final noteFiles =
    directory.listSync().where((file) => file.path.endsWith('.json'));
    List<NoteModel> loadedNotes = [];
    for (var file in noteFiles) {
      final noteContent = await File(file.path).readAsString();
      final noteJson = jsonDecode(noteContent);
      loadedNotes.add(NoteModel.fromJson(noteJson));
    }
    setState(() {
      notes = loadedNotes;
      isLoading = false; // Make sure to stop loading after fetching notes
    });
  }

  List<NoteModel> _sortNotes(String sortOption, List<NoteModel> noteList) {
    switch (sortOption) {
      case 'alphabetic':
        noteList.sort((a, b) => a.noteTitle.compareTo(b.noteTitle));
        break;
      case 'category':
        noteList.sort((a, b) => a.noteType.compareTo(b.noteType));
        break;
      default:
        noteList.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    }
    return noteList;
  }

  Future<void> showOptions(NoteModel note) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) =>
          ListView(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Options'),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.alarm_add),
                title: const Text('Add Reminder'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add),
                title: const Text('Add to bookmarks'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Lock'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Info'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Note'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    fetchNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<String>(
      stream: widget.sortingStream,
      builder: (context, snapshot) {
        final sortOption = snapshot.data ?? 'dateCreated';
        final sortedNotes = _sortNotes(sortOption, notes);

        if (sortedNotes.isEmpty) {
          return const Center(
            child: Text('No notes available'),
          );
        }

        return ListView.builder(
          itemCount: sortedNotes.length,
          itemBuilder: (context, index) {
            NoteModel note = sortedNotes[index];
            return ListTile(
              leading: const Icon(Icons.note),
              title: Text(note.noteTitle),
              subtitle: Text(note.noteType),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showOptions(note);
                },
              ),
              onTap: () {
                showOptions(note);
              },
              onLongPress: () {},
            );
          },
        );
      },
    );
  }
}
