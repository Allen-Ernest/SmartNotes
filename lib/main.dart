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
//TODO: Style the app to have a beautifully UI
//TODO: Add condition to check if note is locked to open note
//TODO: Add more default categories like 10
//TODO: aDD option to modify note category
//TODO: fIX HEX color error
//TODO: Note Sorting ask Gemini