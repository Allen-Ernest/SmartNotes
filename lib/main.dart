import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_notes/routes/routes.dart';
import 'package:smart_notes/settings/themes.dart';
import 'package:smart_notes/notes/view_note.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/notes/note_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/logo_notification', [
    NotificationChannel(
      channelKey: 'scheduled_channel',
      channelName: 'Scheduled Notifications',
      channelDescription: 'Notification channel for scheduled reminders',
      defaultColor: Colors.green,
      ledColor: Colors.white,
      importance: NotificationImportance.High,
    )
  ]);

  AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'OPEN_NOTE') {
      String? noteId = receivedAction.payload?['noteId'];
      if (noteId != null) {
        NoteModel note = await DatabaseHelper().getNoteById(noteId);
        //Remove reminders from note after opening notification
        note.hasReminder = false;
        note.reminderTime = null;
        await DatabaseHelper().updateNote(note);
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => NoteViewingPage(
                  note: note,
                )));
      }
    }
  });
  runApp(const MyNoteBook());
}

class MyNoteBook extends StatelessWidget {
  const MyNoteBook({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'My Notebook',
            theme: themeProvider.isDarkTheme
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            themeAnimationDuration: const Duration(seconds: 1),
            routes: routes,
            initialRoute: '/home',
          );
        }));
  }
}

//TODO: Alarms
//TODO: Format dates
//TODO: App tutorial
//TODO: fIX ERRORS category update error
//TODO: When note is deleted, its notification should be disabled also
