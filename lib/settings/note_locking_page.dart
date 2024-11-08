import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:getwidget/getwidget.dart';

class NoteLockingPage extends StatefulWidget {
  const NoteLockingPage({super.key});

  @override
  State<NoteLockingPage> createState() => _NoteLockingPageState();
}

class _NoteLockingPageState extends State<NoteLockingPage> {
  List<NoteModel> lockedNotes = [];
  bool isNoteLockingConfigured = false;

  fetchLockedNotes() async {
    List<NoteModel> notes = await DatabaseHelper().getNotes();
    List<NoteModel> notesWithLock = [];
    for (var note in notes) {
      if (note.isLocked) {
        notesWithLock.add(note);
      }
      setState(() {
        lockedNotes = notesWithLock;
      });
    }
  }

  void removeLockFromNotes() async {
    if (lockedNotes.isNotEmpty) {
      for (NoteModel note in lockedNotes) {
        setState(() {
          note.isLocked = false;
        });
        await DatabaseHelper().updateNote(note);
      }
      fetchLockedNotes();
    }
  }

  void turnOffLockOnNote(NoteModel note) async {
    final confirmation = await confirmTurningOffLockOnNote(note);
    if (confirmation) {
      setState(() {
        note.isLocked = false;
      });
      int isNoteUpdated = await DatabaseHelper().updateNote(note);
      if (isNoteUpdated == 1) {
        setState(() {
          lockedNotes.remove(note);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to remove lock from note")));
      }
    } else {
      return;
    }
  }

  Future<bool> confirmTurningOffLockOnNote(NoteModel note) async {
    TextEditingController controller = TextEditingController();
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Insert PIN to remove lock on ${note.noteTitle}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    label: const Icon(Icons.pin, color: Colors.green),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green)),
                  ),
                )
              ],
            ),
            actions: [
              GFButton(
                  onPressed: () async {
                    FlutterSecureStorage storage = const FlutterSecureStorage();
                    String? pin = await storage.read(key: 'pin');
                    if (pin != null) {
                      String insertedPIN = controller.text.trim();
                      if (insertedPIN == pin) {
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pop(context, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invalid PIN")));
                      }
                    } else {
                      return;
                    }
                  },
                  text: 'Confirm',
                  textColor: Colors.green,
                  type: GFButtonType.outline,
                  borderSide: const BorderSide(color: Colors.green)),
              GFButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                color: Colors.green,
                text: 'Cancel',
                borderSide: const BorderSide(color: Colors.green),
              )
            ],
          );
        });
    return confirmation;
  }

  Future<bool> confirmTurningOffLockOnAllNotes() async {
    final TextEditingController controller = TextEditingController();
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Confirm unlocking all notes')]),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  label: const Icon(Icons.pin),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green)),
                ),
              ),
            ));
    return confirmation;
  }

  void getLockingState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? feedback = preferences.getBool('isNoteLockingConfigured');
    setState(() {
      isNoteLockingConfigured = feedback ?? false;
    });
  }

  void enableNoteLock() async {
    TextEditingController controller1 = TextEditingController();
    TextEditingController controller2 = TextEditingController();
    bool isPINVisible = false;
    String feedback = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            var height = MediaQuery.of(context).size.height;
            void togglePINVisibility() {
              setDialogState(() {
                isPINVisible = !isPINVisible;
              });
            }

            return AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Set Unlock PIN')]),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      autofocus: true,
                      controller: controller1,
                      keyboardType: TextInputType.number,
                      obscureText: !isPINVisible,
                      maxLength: 4,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12)),
                          label: const Icon(Icons.pin, color: Colors.green),
                          suffixIcon: IconButton(
                              onPressed: () {
                                togglePINVisibility();
                              },
                              icon: isPINVisible
                                  ? const Icon(
                                      Icons.visibility_off,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.visibility,
                                      color: Colors.green,
                                    ))),
                    ),
                    SizedBox(height: height * 0.03),
                    TextField(
                      controller: controller2,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                          label: const Icon(Icons.check_circle,
                              color: Colors.green),
                          hintText: 'Verify PIN',
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(feedback)
                  ],
                ),
              ),
              actions: <Widget>[
                GFButton(
                    onPressed: () async {
                      String pin1 = controller1.text.trim().toString();
                      String pin2 = controller2.text.trim().toString();
                      if (pin1 != pin2) {
                        setDialogState(() {
                          feedback = 'PINS not matching, please try again';
                          return;
                        });
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setBool('isNoteLockingConfigured', true);
                        FlutterSecureStorage storage =
                            const FlutterSecureStorage();
                        storage.write(key: 'pin', value: pin1);
                        setState(() {
                          isNoteLockingConfigured = true;
                        });
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (Route<dynamic> route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            showCloseIcon: true,
                            duration: Duration(seconds: 8),
                            content: Text(
                                'Successfully configured not locking, you can now lock your notes, use the PIN submitted to unlock locked notes')));
                      }
                    },
                    text: "Set PIn",
                  textColor: Colors.green,
                  type: GFButtonType.outline,
                  borderSide: const BorderSide(color: Colors.green)
                ),
                GFButton(
                borderSide: const BorderSide(color: Colors.green),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: "Cancel")
              ],
            );
          });
        });
  }

  void disableNoteLock() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isNoteLockingEnabled =
        preferences.getBool('isNoteLockingConfigured') ?? false;
    if (isNoteLockingEnabled == false) {
      return;
    } else {
      bool confirmation = await confirmDisablingNoteLocking();
      if (confirmation == true) {
        FlutterSecureStorage storage = const FlutterSecureStorage();
        preferences.setBool('isNoteLockingConfigured', false);
        storage.delete(key: 'pin');
        for (var note in lockedNotes) {
          setState(() {
            note.isLocked = false;
          });
          await DatabaseHelper().updateNote(note);
        }
        setState(() {
          lockedNotes.clear();
          isNoteLockingConfigured = false;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid PIN')));
        return;
      }
    }
  }

  Future<bool> confirmDisablingNoteLocking() async {
    TextEditingController controller = TextEditingController();
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirm Disabling note locking',
              textAlign: TextAlign.center,
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                  label: const Icon(Icons.pin, color: Colors.green),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(12))),
            ),
            actions: <Widget>[
              GFButton(
                  onPressed: () async {
                    FlutterSecureStorage storage = const FlutterSecureStorage();
                    String? pin = await storage.read(key: 'pin');
                    if (pin != null) {
                      String submittedPin = controller.text.trim();
                      if (pin == submittedPin) {
                        Navigator.of(context).pop(true);
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  text: "Confirm",
                  type: GFButtonType.outline,
                  borderSide: const BorderSide(color: Colors.green),
                  textColor: Colors.green),
              GFButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  text: 'Cancel',
                  color: Colors.green,
                  borderSide: const BorderSide(color: Colors.green)),
            ],
          );
        });
    return confirmation;
  }

  @override
  void initState() {
    getLockingState();
    fetchLockedNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure note locking')),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              isNoteLockingConfigured
                  ? ListTile(
                      leading: const Icon(Icons.lock_open),
                      title: const Text('Disable note locking'),
                      onTap: disableNoteLock,
                    )
                  : ListTile(
                      leading: const Icon(Icons.pin),
                      title: const Text('Set PIN'),
                      onTap: () {
                        enableNoteLock();
                      },
                    ),
              const Text('Locked Notes', style: TextStyle(fontSize: 18)),
              if (lockedNotes.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: lockedNotes.length,
                    itemBuilder: (context, index) {
                      final lockedNote = lockedNotes[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.edit_note, color: Colors.green),
                        title: Text(lockedNote.noteTitle),
                        subtitle: Text(lockedNote.noteType),
                        trailing: IconButton(
                            onPressed: () {
                              turnOffLockOnNote(lockedNote);
                            },
                            icon: const Icon(Icons.lock_open)),
                      );
                    },
                  ),
                )
              else
                const Text('No locked notes available')
            ],
          )),
    );
  }
}
