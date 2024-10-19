import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/bookmarks/search_for_bookmarks.dart';

import '../notes/view_note.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<NoteModel> bookmarkedNotes = [];
  bool isLoading = true;

  void fetchBookmarks() async {
    List<NoteModel> loadedNotes = await DatabaseHelper().getNotes();
    for (var note in loadedNotes) {
      if (note.isBookmarked) {
        setState(() {
          bookmarkedNotes.add(note);
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void openBookmark(NoteModel note) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
  }

  void removeFromBookmarks(NoteModel note) async {
    setState(() {
      note.isBookmarked = false;
      bookmarkedNotes.remove(note);
    });
    await DatabaseHelper().updateNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${note.noteTitle} removed from Bookmarks')));
  }

  void deleteNote(NoteModel note) async {
    final confirmation = await confirmDelete(note);
    if (confirmation == true) {
      int deleteNote = await DatabaseHelper().deleteNote(note.noteId);
      if (deleteNote == 1) {
        setState(() {
          bookmarkedNotes.remove(note);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully Deleted ${note.noteTitle}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable delete ${note.noteTitle}')));
      }
    }
  }

  Future<bool> confirmDelete(NoteModel note) async {
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Confirm Delete')],
            ),
            content: Text('Delete ${note.noteTitle}?'),
            actions: <TextButton>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'YES',
                    style: TextStyle(color: Colors.green),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    'NO',
                    style: TextStyle(color: Colors.green),
                  ))
            ],
          );
        });
    return confirmation;
  }

  void renameNote(NoteModel note) async {
    final TextEditingController controller = TextEditingController();
    String? message;
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogSate) {
              var height = MediaQuery.of(context).size.height;
              return AlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Text('Rename ${note.noteTitle}'))
                    ]),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'New title',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green)),
                      ),
                    ),
                    if (message != null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: height * 0.03),
                          Text(message!),
                        ],
                      )
                  ],
                ),
                actions: <TextButton>[
                  TextButton(
                      onPressed: () async {
                        final String newTitle = controller.text.trim();
                        if (newTitle.toLowerCase() ==
                            note.noteTitle.toLowerCase()) {
                          setDialogSate(() {
                            message = 'Please, use a new title';
                          });
                          return;
                        }
                        setState(() {
                          note.noteTitle = newTitle;
                        });
                        int isNotUpdated =
                            await DatabaseHelper().updateNote(note);
                        if (isNotUpdated == 1) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Successfully renamed note')));
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed renaming note')));
                        }
                      },
                      child: const Text('Rename',
                          style: TextStyle(color: Colors.green))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.green)))
                ],
              );
            }));
  }

  void showOptions(NoteModel note) async {
    showModalBottomSheet(
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Actions', style: TextStyle(fontSize: 17)),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_remove_sharp),
                title: const Text('Remove from bookmarks'),
                onTap: () {
                  Navigator.pop(context);
                  removeFromBookmarks(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.alarm_add),
                title: const Text('Add Reminder'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('Rename note'),
                onTap: () {
                  Navigator.pop(context);
                  renameNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete note'),
                onTap: () {
                  Navigator.pop(context);
                  deleteNote(note);
                },
              ),
            ],
          );
        });
  }

  Future<bool> confirmClearingBookmarks() async {
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Expanded(child: Text('Clear Bookmarks'))]),
              content: Text(
                  'Confirm Clearing all ${bookmarkedNotes.length} notes from bookmarks'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.green))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.green)))
              ],
            ));
    return confirmation;
  }

  void clearBookmarks() async {
    final bool confirmation = await confirmClearingBookmarks();
    if (confirmation) {
      for (var note in bookmarkedNotes) {
        setState(() {
          note.isBookmarked = false;
        });
        await DatabaseHelper().updateNote(note);
      }
      setState(() {
        bookmarkedNotes.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Cleared all ${bookmarkedNotes.length} bookmarks successfully')));
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
          if (bookmarkedNotes.isNotEmpty)
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => SearchForBookmarks(
                            bookmarks: bookmarkedNotes,
                          )));
                },
                icon: const Icon(Icons.search, color: Colors.green)),
          if (bookmarkedNotes.isNotEmpty)
            IconButton(
                onPressed: () {
                  clearBookmarks();
                },
                icon: const Icon(Icons.bookmark_remove_outlined,
                    color: Colors.green))
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
                                onPressed: () {
                                  showOptions(note);
                                },
                                icon: const Icon(Icons.more_vert)),
                            onTap: () {
                              openBookmark(note);
                            },
                          );
                        })));
  }
}
