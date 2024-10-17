import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/notes/view_note.dart';

class SearchResults extends StatefulWidget {
  SearchResults({super.key, required this.resultsList});

  List<NoteModel> resultsList;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  void openNote(NoteModel note) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
  }

  void showOptions(NoteModel note){
    showModalBottomSheet(
      context: context,
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
              toggleBookmark(note, false);
              Navigator.pop(context);
            },
          )
              : ListTile(
            leading: const Icon(Icons.bookmark_add),
            title: const Text('Add to bookmarks'),
            onTap: () {
              toggleBookmark(note, true);
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
              showInfo(note);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Note'),
            onTap: () {
              Navigator.pop(context);
              deleteNote(note);
            },
          ),
        ],
      )
    );
  }

  void toggleBookmark(NoteModel note, bool isBookmarked) async {
    setState(() {
      note.isBookmarked = isBookmarked;
    });

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${note.noteTitle}.json');
    if (await file.exists()) {
      final updatedNoteJson = jsonEncode(note.toJson());
      await file.writeAsString(updatedNoteJson);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully added ${note.noteTitle} to bookmarks')));
    }
  }

  void deleteNote(NoteModel note) async {
    bool confirmation = await confirmDelete(note);
    if (confirmation) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${note.noteTitle}.json');
      if (await file.exists()) {
        await file.delete();
        setState(() {
          widget.resultsList.remove(note);
        });
      }
    } else {
      return;
    }
  }

  Future<bool> confirmDelete(NoteModel note) async {
    bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Delete Note')]),
            content: Text('Confirm deleting note ${note.noteTitle}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('YES',
                      style: TextStyle(color: Colors.green))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('NO',
                      style: TextStyle(color: Colors.green)))
            ]));
    return isConfirmed;
  }

  void showInfo(NoteModel note) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.info)],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.title),
                  title: Text(note.noteTitle),
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(note.noteType),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(note.dateCreated.toString()),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    List<NoteModel> results = widget.resultsList;
    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          if (results.isNotEmpty) {
            NoteModel note = results[index];
            return ListTile(
              leading: const Icon(Icons.checklist_outlined),
              title: Text(note.noteTitle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert))
                ],
              ),
              onTap: () {
                openNote(note);
              },
            );
          } else {
            return const Center(child: Text('No items matching your query'));
          }
        });
  }
}
