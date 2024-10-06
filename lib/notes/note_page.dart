import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_notes/notes/view_note.dart';

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
      isLoading = false;
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

  Future<void> addNoteToBookmarks(NoteModel note) async {
    setState(() {
      note.isBookmarked = true;
    });
    final bookmarkedNote = NoteModel(
        noteId: note.noteId,
        noteTitle: note.noteTitle,
        noteType: note.noteType,
        noteContent: note.noteContent,
        dateCreated: note.dateCreated,
        isBookmarked: true);
    await _saveNoteToFile(bookmarkedNote);
    debugPrint(bookmarkedNote.isBookmarked.toString());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully added ${note.noteTitle} to bookmarks')));
  }

  Future<void> removeNoteFromBookmarks(NoteModel note) async {
    setState(() {
      note.isBookmarked = false;
    });
    final unBookmarkedNote = NoteModel(
      noteId: note.noteId,
      noteTitle: note.noteTitle,
      noteType: note.noteType,
      noteContent: note.noteContent,
      dateCreated: note.dateCreated,
    );
    await _saveNoteToFile(unBookmarkedNote);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully removed ${note.noteTitle} to bookmarks')));
  }

  Future<void> _saveNoteToFile(NoteModel note) async {
    final directory = await getApplicationDocumentsDirectory();
    final noteFile = File('${directory.path}/${note.noteTitle}.json');
    if (await noteFile.exists()){
      await noteFile.writeAsString(jsonEncode(note.toJson()));
      fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note is bookmarked?: ${note.isBookmarked}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File does not exist')));
    }
  }

  Future<void> showOptions(NoteModel note) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => ListView(
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
          note.isBookmarked
              ? ListTile(
                  leading: const Icon(Icons.bookmark_remove),
                  title: const Text('Remove from bookmarks'),
                  onTap: () {
                    removeNoteFromBookmarks(note);
                    Navigator.pop(context);
                  },
                )
              : ListTile(
                  leading: const Icon(Icons.bookmark_add),
                  title: const Text('Add to bookmarks'),
                  onTap: () {
                    addNoteToBookmarks(note);
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

  void openNote(NoteModel note) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
  }

  @override
  void initState() {
    fetchNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.green,
          ))
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
                      openNote(note);
                    },
                    onLongPress: () {},
                  );
                },
              );
            },
          );
  }
}
