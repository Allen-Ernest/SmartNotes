import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_notes/routes/routes.dart';
import 'package:smart_notes/settings/themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyNoteBook());
}

class MyNoteBook extends StatelessWidget {
  const MyNoteBook({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ThemeProvider(), child: Consumer<ThemeProvider>(builder: (context, themeProvider, child){
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Notebook',
        theme: themeProvider.isDarkTheme ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
        routes: routes,
        initialRoute: '/home',
      );
    }));
  }
}

//TODO: Alarms - Tomorrow
//TODO: Logo
//TODO: Format dates
//TODO: App rating
//TODO: When note locking gets disabled, all notes that were locked should be unlocked - Today
//TODO: Style the app to have a beautifully UI
//TODO: Note locking
//TODO: Implement fetchNotes note locking page, then implement category colors and icons for fetched notes - Today
//TODO: Search and open bookmarks - Next