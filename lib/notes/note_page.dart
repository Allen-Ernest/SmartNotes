import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_notes/notes/view_note.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/settings/category_model.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<NoteModel> notes = [];
  bool isLoading = true;
  List<CategoryModel> categories = [];

  Future<void> loadNotes() async {
    List<NoteModel> savedNotes = await DatabaseHelper().getNotes();
    setState(() {
      notes = savedNotes;
      isLoading = false;
    });
  }

  void showInfo(NoteModel note) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.green,
                  )
                ],
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

  Future<void> showOptions(NoteModel note) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => ListView(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Actions'),
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
              renameNote(note);
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
      ),
    );
  }

  void openNote(NoteModel note) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
  }

  void deleteNote(NoteModel note) async {
    bool confirmation = await confirmDelete(note);
    if (confirmation) {
      int isNoteDeleted = await DatabaseHelper().deleteNote(note.noteId);
      if (isNoteDeleted == 1) {
        setState(() {
          notes.remove(note);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${note.noteTitle} Successfully deleted')));
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

  Future<void> toggleBookmark(NoteModel note, bool isBookmarked) async {
    setState(() {
      note.isBookmarked = isBookmarked;
    });
    await DatabaseHelper().updateNote(note);
    note.isBookmarked
        ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${note.noteTitle} added to bookmarks')))
        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${note.noteTitle} removed from bookmarks')));
  }

  void toggleNoteLock(NoteModel note) async {
    if (note.isLocked) {
      bool confirmation = await removeLock(note);
      if (confirmation) {
        setState(() {
          note.isLocked = false;
        });
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${note.noteTitle}.json');
        if (await file.exists()) {
          final updatedNoteJson = jsonEncode(note.toJson());
          await file.writeAsString(updatedNoteJson);
        }
      } else {
        return;
      }
    } else {
      bool confirmation = await confirmLocking(note);
      if (confirmation) {
        setState(() {
          note.isLocked = true;
        });
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${note.noteTitle}.json');
        if (await file.exists()) {
          final updatedNoteJson = jsonEncode(note.toJson());
          await file.writeAsString(updatedNoteJson);
        }
      } else {
        return;
      }
    }
  }

  Future<bool> confirmLocking(NoteModel note) async {
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Lock note')],
              ),
              content: Text('Confirm locking of ${note.noteTitle}'),
              actions: <Widget>[
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
                    child:
                        const Text('NO', style: TextStyle(color: Colors.green)))
              ],
            ));
    return confirmation;
  }

  Future<bool> removeLock(NoteModel note) async {
    String message = '';
    TextEditingController controller = TextEditingController();
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              var height = MediaQuery.of(context).size.height;
              return AlertDialog(
                title: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Remove Lock')]),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.green.withOpacity(0.1)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            style: const TextStyle(color: Colors.green),
                            'Insert unlock PIN to confirming removing lock from ${note.noteTitle}'),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: const Icon(Icons.pin),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(message)
                  ]),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        String insertedPIN = controller.text.trim();
                        FlutterSecureStorage storage =
                            const FlutterSecureStorage();
                        String? savedPIN = await storage.read(key: 'pin');
                        if (savedPIN != null) {
                          if (insertedPIN == savedPIN) {
                            Navigator.pop(context, true);
                          } else {
                            setDialogState(() {
                              message = 'Wrong PIN, please try again';
                            });
                          }
                        } else {
                          return;
                        }
                      },
                      child: const Text('YES',
                          style: TextStyle(color: Colors.green))),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child:
                        const Text('NO', style: TextStyle(color: Colors.green)),
                  ),
                ],
              );
            },
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
                    children: [Text('Rename ${note.noteTitle}')]),
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

  void loadCategories() async {
    List<CategoryModel> savedCategories =
        await DatabaseHelper().getCategories();
    setState(() {
      categories = savedCategories;
    });
  }

  @override
  void initState() {
    loadNotes();
    loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.green,
          ))
        : notes.isNotEmpty
            ? ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  NoteModel note = notes[index];
                  CategoryModel category = categories.firstWhere(
                      (cat) => cat.categoryTitle == note.noteType,
                      orElse: () => CategoryModel(
                          categoryId: 'default',
                          categoryTitle: 'Default',
                          categoryColor: '0xFFFF0000',
                          categoryIcon: Icons.note.codePoint,
                          fontFamily: 'MaterialIcons'));
                  return ListTile(
                    leading: Icon(
                      IconData(category.categoryIcon,
                          fontFamily: category.fontFamily),
                      color: Color(int.parse(
                          category.categoryColor, radix: 16)),
                    ),
                    title: Text(note.noteTitle),
                    subtitle: Text(note.noteType),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (note.isBookmarked) const Icon(Icons.bookmark),
                        if (note.isLocked) const Icon(Icons.lock),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showOptions(note);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      openNote(note);
                    },
                    tileColor: Color(int.parse(
                            category.categoryColor,
                            radix: 16))
                        .withOpacity(0.1),
                  );
                },
              )
            : const Center(child: Text('No notes available'));
  }
}
