import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final List<NoteModel> _reminderNotes = [];

  Future<void> _fetchReminderNotes() async {}

  void _clearReminders() async {}

  void _highlightReminderNote(NoteModel reminderNote) {}

  void _openNote(NoteModel reminderNote) async {}

  void _removeReminder(NoteModel reminderNote) async {}

  void _removeBookmark(NoteModel reminderNote) async {}

  void _addToBookmarks(NoteModel reminderNote) async {}

  void _exportToPDF(NoteModel reminderNote) async {}

  void _deleteNotes(List<NoteModel> notes) async {}

  void _showOptions(NoteModel reminderNote) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.alarm_off),
                title: const Text('Remove reminder'),
                onTap: () {
                  _removeReminder(reminderNote);
                },
              ),
              if (reminderNote.isBookmarked == true)
                ListTile(
                  leading: const Icon(Icons.bookmark_remove_sharp),
                  title: const Text('Remove from bookmarks'),
                  onTap: () {
                    _removeBookmark(reminderNote);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Add to bookmarks'),
                  onTap: () {
                    _addToBookmarks(reminderNote);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export to PDF'),
                onTap: () {
                  _exportToPDF(reminderNote);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Note'),
                onTap: () {
                  _deleteNotes([reminderNote]);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchReminderNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Scaffold(
              //Use FutureBuilder
              appBar: AppBar(
                title: const Text('My Reminders'),
                actions: [
                  IconButton(
                      onPressed: _clearReminders,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ))
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _reminderNotes.isEmpty
                    ? const Center(child: Text('No Reminders'))
                    : ListView.builder(itemBuilder: (context, index) {
                        NoteModel reminderNote = _reminderNotes[index];
                        return ListTile(
                          leading: const Icon(Icons.alarm),
                          title: Text(reminderNote.noteTitle),
                          trailing: IconButton(
                            onPressed: () {
                              _showOptions(reminderNote);
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                          subtitle: Text(
                              '${reminderNote.noteType} - ${reminderNote.reminderTime}'),
                          onTap: () {
                            _openNote(reminderNote);
                          },
                          onLongPress: () {
                            _highlightReminderNote(reminderNote);
                          },
                        );
                      }),
              ),
            );
          }
        });
  }
}
