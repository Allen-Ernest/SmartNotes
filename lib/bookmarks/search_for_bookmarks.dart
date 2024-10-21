import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

import '../categories/category_model.dart';
import '../database/database_helper.dart';
import '../notes/view_note.dart';

class SearchForBookmarks extends StatefulWidget {
  const SearchForBookmarks({super.key, required this.bookmarks});

  final List<NoteModel> bookmarks;

  @override
  State<SearchForBookmarks> createState() => _SearchForBookmarksState();
}

class _SearchForBookmarksState extends State<SearchForBookmarks> {
  TextEditingController controller = TextEditingController();
  List<NoteModel> filteredBookmarks = [];

  @override
  void initState() {
    filteredBookmarks = widget.bookmarks;
    controller.addListener(() {
      setState(() {
        filteredBookmarks = widget.bookmarks.where((bookmark) {
          final query = controller.text.toLowerCase();
          return bookmark.noteTitle.toLowerCase().contains(query);
        }).toList();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for bookmarks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(
                  label: const Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(12))),
            ),
            SizedBox(height: height * 0.02),
            Expanded(child: BookmarksSearchResults(results: filteredBookmarks))
          ],
        ),
      ),
    );
  }
}

class BookmarksSearchResults extends StatefulWidget {
  const BookmarksSearchResults({super.key, required this.results});

  final List<NoteModel> results;

  @override
  State<BookmarksSearchResults> createState() => _BookmarksSearchResultsState();
}

class _BookmarksSearchResultsState extends State<BookmarksSearchResults> {
  List<CategoryModel> categories = [];

  void loadCategories() async {
    List<CategoryModel> savedCategories =
        await DatabaseHelper().getCategories();
    setState(() {
      categories = savedCategories;
    });
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

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return const Center(child: Text('No bookmarks found'));
    }
    void openBookmark(NoteModel note) async {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NoteViewingPage(note: note)));
    }

    void removeFromBookmarks(NoteModel note) async {
      setState(() {
        note.isBookmarked = false;
        widget.results.remove(note);
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
            widget.results.remove(note);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Successfully Deleted ${note.noteTitle}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable delete ${note.noteTitle}')));
        }
      }
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
                              borderSide:
                                  const BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.green)),
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
                                    content:
                                        Text('Successfully renamed note')));
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

    return ListView.builder(
      itemCount: widget.results.length,
      itemBuilder: (context, index) {
        NoteModel note = widget.results[index];
        CategoryModel category = categories.firstWhere(
            (cat) => cat.categoryTitle == note.noteType,
            orElse: () => CategoryModel(
                categoryId: 'default',
                categoryTitle: 'Default',
                categoryColor: '0xFF0000',
                categoryIcon: Icons.note.codePoint,
                fontFamily: 'MaterialIcons'));
        return Container(
          color: Color(int.parse(category.categoryColor.replaceFirst('0x', ''),
                  radix: 16))
              .withOpacity(0.1),
          child: ListTile(
            leading: Icon(
                IconData(category.categoryIcon,
                    fontFamily: category.fontFamily),
                color: Color(int.parse(
                        category.categoryColor.replaceFirst('0x', ''),
                        radix: 16))),
            title: Text(note.noteTitle),
            subtitle: Text(note.noteType),
            onTap: () {
              openBookmark(note);
            },
            trailing: IconButton(
                onPressed: () {
                  showOptions(note);
                },
                icon: const Icon(Icons.more_vert)),
          ),
        );
      },
    );
  }
}