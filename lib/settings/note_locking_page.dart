import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:path_provider/path_provider.dart';

class NoteLockingPage extends StatefulWidget {
  const NoteLockingPage({super.key});

  @override
  State<NoteLockingPage> createState() => _NoteLockingPageState();
}

class _NoteLockingPageState extends State<NoteLockingPage> {
  List<NoteModel> lockedNotes = [];

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
  }

  late bool isNoteLockingConfigured;

  void removeLockFromNotes() async {
    if (lockedNotes.isNotEmpty){
      for (NoteModel note in lockedNotes){
        //Set isLocked property to false
      }
    }
  }

  Future<bool> getLockingState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? feedback = preferences.getBool('isNoteLockingConfigured');
    return feedback ?? false;
  }

  void enableNoteLock() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            TextEditingController controller1 = TextEditingController();
            TextEditingController controller2 = TextEditingController();
            var height = MediaQuery.of(context).size.height;
            bool isPINVisible = false;
            void togglePINVisibility() {
              setDialogState(() {
                isPINVisible = !isPINVisible;
              });
            }

            String feedback = '';
            return AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Set Unlock PIN')]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: controller1,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Icon(Icons.pin),
                        suffixIcon: IconButton(
                            onPressed: () {
                              togglePINVisibility();
                            },
                            icon: isPINVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility))),
                  ),
                  SizedBox(height: height * 0.05),
                  TextField(
                    controller: controller2,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      label: const Icon(Icons.check_circle),
                        hintText: 'Verify PIN',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                  SizedBox(height: height * 0.05),
                  Text(feedback)
                ],
              ),
              actions: <Widget>[
                TextButton(
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            showCloseIcon: true,
                            duration: Duration(seconds: 8),
                            content: Text(
                                'Successfully configured not locking, you can now lock your notes, use the PIN submitted to unlock locked notes')));
                      }
                    },
                    child: const Text('Set PIN')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'))
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
      } else {
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
            title: const Text('Confirm Disabling note locking'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            actions: <Widget>[
              TextButton(
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
                  child: const Text('Confirm')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel')),
            ],
          );
        });
    return confirmation;
  }

  @override
  void initState() async {
    isNoteLockingConfigured = await getLockingState();
    fetchNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure note locking')),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isNoteLockingConfigured
              ? ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: const Text('Disable note locking'),
                  onTap: disableNoteLock,
                )
              : ListTile(
                  leading: const Icon(Icons.pin),
                  title: const Text('Set PIN'),
                  onTap: enableNoteLock,
                )),
    );
  }
}
