import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/notes/view_note.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/categories/category_model.dart';

class NotePage extends StatefulWidget {
  const NotePage(
      {super.key,
      required this.sortingMode,
      required this.onSortingModeChanged});

  final Function onSortingModeChanged;
  final String sortingMode;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<NoteModel> notes = [];
  bool isLoading = true;
  List<CategoryModel> categories = [];

  Future<void> loadNotes() async {
    List<NoteModel> savedNotes = await DatabaseHelper().getNotes();
    sortNotes(savedNotes, widget.sortingMode);
    setState(() {
      notes = savedNotes;
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${savedNotes.length} notes have been loaded')));
  }

  void sortNotes(List<NoteModel> noteList, String sortingMode) {
    switch (sortingMode) {
      case 'alphabetic-ascending':
        noteList.sort((a, b) =>
            a.noteTitle.toLowerCase().compareTo(b.noteTitle.toLowerCase()));
        break;
      case 'alphabetic-descending':
        noteList
            .sort((a, b) => b.noteTitle.toLowerCase().compareTo(a.noteTitle));
        break;
      case 'dateCreated-ascending':
        noteList.sort((a, b) =>
            b.dateCreated.compareTo(a.dateCreated)); // Most recent first
        break;
      case 'dateCreated-descending':
        noteList.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      case 'type':
        noteList.sort((a, b) =>
            a.noteType.toLowerCase().compareTo(b.noteType.toLowerCase()));
        break;
      default:
        noteList.sort((a, b) =>
            a.noteTitle.toLowerCase().compareTo(b.noteTitle.toLowerCase()));
        break;
    }
  }

  void changeSortingMode(String newMode) {
    widget.onSortingModeChanged(newMode);
    setState(() {
      sortNotes(notes, newMode);
    });
    debugPrint('SortingMode changed $newMode');
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

  void toggleLock(NoteModel note) async {
    if (note.isLocked) {
      bool confirmation = await confirmPIN();
      if (confirmation) {
        setState(() {
          note.isLocked = false;
        });
        int isNotUnlocked = await DatabaseHelper().updateNote(note);
        if (isNotUnlocked == 1) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Successfully removed lock from ${note.noteTitle}')));
        }
      }
    } else {
      bool isLockingConfigured = await getLockingState();
      if (isLockingConfigured) {
        setState(() {
          note.isLocked = true;
        });
        await DatabaseHelper().updateNote(note);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${note.noteTitle} is now locked')));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Icon>[
                      Icon(Icons.info_outline, color: Colors.green)
                    ],
                  ),
                  content: Container(
                    color: Colors.green.withOpacity(0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          style: TextStyle(color: Colors.green),
                          'Note locking is not configured, please go to settings to configure not locking',
                          textAlign: TextAlign.justify),
                    ),
                  ),
                  actions: <TextButton>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/lock_note');
                        },
                        child: const Text('Go to Settings',
                            style: TextStyle(color: Colors.green))),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.green))),
                  ],
                ));
      }
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

  Future<bool> getLockingState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? feedback = preferences.getBool('isNoteLockingConfigured');
    return feedback ?? false;
  }

  Future<void> changeNoteCategory(NoteModel note) async {
    TextEditingController categoryController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text('Change Note Category'),
                  )
                ],
              ),
              content: DropdownMenu(
                  hintText: 'Select Category',
                  controller: categoryController,
                  dropdownMenuEntries:
                      categories.map<DropdownMenuEntry<String>>((category) {
                    return DropdownMenuEntry<String>(
                        value: category.categoryId,
                        label: category.categoryTitle,
                        leadingIcon: Icon(IconData(category.categoryIcon,
                            fontFamily: category.fontFamily)));
                  }).toList()),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      final String newCategory = categoryController.text.trim();
                      if (newCategory == note.noteType) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No changes made in note category')));
                        return;
                      }
                      if (newCategory.isEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Note category not updated')));
                        return;
                      }
                      setState(() {
                        note.noteType = newCategory;
                      });
                      await DatabaseHelper().updateNote(note);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Successfully updated note category')));
                    },
                    child: const Text('Change Category',
                        style: TextStyle(color: Colors.green))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.green)))
              ],
            );
          });
        });
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
              toggleReminder(note);
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
            leading: note.isLocked
                ? const Icon(Icons.lock_open)
                : const Icon(Icons.lock),
            title: note.isLocked
                ? const Text('Unlock note')
                : const Text('Lock note'),
            onTap: () {
              Navigator.pop(context);
              toggleLock(note);
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
            leading: const Icon(Icons.category),
            title: const Text('Change note category'),
            onTap: () {
              Navigator.pop(context);
              changeNoteCategory(note);
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

  void toggleReminder(NoteModel note) async {
    if (note.hasReminder) {
      setState(() {
        note.hasReminder = false;
      });
      await DatabaseHelper().updateNote(note);
      //Disable notification
    } else {
      //Schedule date and time
      //Enable notification
      setState(() {
        note.hasReminder = false;
      });
      await DatabaseHelper().updateNote(note);
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
                          categoryColor: '0xFF0000',
                          categoryIcon: Icons.note.codePoint,
                          fontFamily: 'MaterialIcons'));
                  return Container(
                    color: Color(int.parse(category.categoryColor.replaceFirst('0x', ''), radix: 16))
                        .withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        IconData(category.categoryIcon,
                            fontFamily: category.fontFamily),
                        color:
                            Color(int.parse(category.categoryColor, radix: 16)),
                      ),
                      title: Text(note.noteTitle),
                      subtitle: Text(note.noteType),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (note.isBookmarked)
                            const Icon(Icons.bookmark_outline_sharp),
                          if (note.isLocked) const Icon(Icons.lock_outlined),
                          if (note.hasReminder) const Icon(Icons.alarm_on),
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
                    ),
                  );
                },
              )
            : const Center(child: Text('No notes available'));
  }
}
