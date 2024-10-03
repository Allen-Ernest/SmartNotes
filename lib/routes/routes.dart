import 'package:flutter/material.dart';
import 'package:smart_notes/exports/exportsPage.dart';
import 'package:smart_notes/notes/create_note.dart';
import 'package:smart_notes/home.dart';
import 'package:smart_notes/notifications/reminders_page.dart';
import 'package:smart_notes/bookmarks/bookmarksPage.dart';
import 'package:smart_notes/settings/note_categorization.dart';
import 'package:smart_notes/settings/settingsPage.dart';
import 'package:smart_notes/settings/note_locking_page.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/home': (context) => const HomePage(),
  '/create_note': (context) => const CreateNote(),
  '/reminders': (context) => const RemindersPage(),
  '/bookmarks': (context) => const BookmarksPage(),
  '/exports': (context) => const ExportsPage(),
  '/settings': (context) => const SettingsPage(),
  '/category': (context) => const NoteCategorizationPage(),
  '/lock_note': (context) => const NoteLockingPage()
};