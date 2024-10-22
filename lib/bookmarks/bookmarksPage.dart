import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/bookmarks/search_for_bookmarks.dart';
import 'package:smart_notes/categories/category_model.dart';
import '../notes/view_note.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<NoteModel> bookmarkedNotes = [];
  List<CategoryModel> categories = [];
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
    if (note.isLocked) {
      bool isAuthenticated = await confirmPIN();
      if (isAuthenticated) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteViewingPage(note: note)));
      } else {
        return;
      }
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
    }
  }

  Future<bool> confirmPIN() async {
    final TextEditingController controller = TextEditingController();
    String message = '';
    bool? confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              var height = MediaQuery.of(context).size.height;
              return AlertDialog(
                title: const Row(
                  children: [
                    Expanded(
                      child: Text('Insert PIN to proceed'),
                    )
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      obscureText: true,
                      controller: controller,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                          label: const Icon(Icons.pin),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    if (message.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: height * 0.03),
                          Text(message)
                        ],
                      )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        FlutterSecureStorage storage =
                        const FlutterSecureStorage();
                        String submittedPIN = controller.text.trim();
                        String? storedPIN = await storage.read(key: 'pin');
                        if (storedPIN == null) {
                          Navigator.pop(context, false);
                          return;
                        }
                        if (submittedPIN == storedPIN) {
                          Navigator.pop(context, true);
                        } else {
                          Navigator.pop(context, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid PIN')));
                        }
                      },
                      child: const Text('Proceed',
                          style: TextStyle(color: Colors.green))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.green)))
                ],
              );
            }));
    return confirmation ?? false;
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

  void loadCategories() async {
    List<CategoryModel> savedCategories =
    await DatabaseHelper().getCategories();
    setState(() {
      categories = savedCategories;
    });
  }

  @override
  void initState() {
    fetchBookmarks();
    loadCategories();
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
                          CategoryModel category = categories.firstWhere(
                                  (cat) => cat.categoryTitle == note.noteType,
                              orElse: () => CategoryModel(
                                  categoryId: 'default',
                                  categoryTitle: 'Default',
                                  categoryColor: '0xFF0000',
                                  categoryIcon: Icons.note.codePoint,
                                  fontFamily: 'MaterialIcons'));
                          return ListTile(
                            leading: Icon(IconData(category.categoryIcon,
                                fontFamily: category.fontFamily),
                              color:
                              Color(int.parse(category.categoryColor.replaceFirst('0x', ''), radix: 16))),
                            title: Text(note.noteTitle),
                            tileColor: Color(int.parse(category.categoryColor.replaceFirst('0x', ''), radix: 16))
                                .withOpacity(0.1),
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
