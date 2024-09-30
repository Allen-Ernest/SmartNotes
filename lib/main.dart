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

//TODO: Add themes
//TODO: Alarms
//TODO: Exports
//TODO: Remove app lock
//TODO: aDD Github repository
//TODO: Logo
//TODO: Note sorting
//TODO: Add categories to editor