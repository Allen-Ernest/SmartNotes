import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_notes/settings/themes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(padding: const EdgeInsets.all(8.0), child: Column(
        children: <ListTile>[
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Note Settings'),
            onTap: (){
              Navigator.pushNamed(context, '/note_settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('App lock'),
            onTap: (){
              Navigator.pushNamed(context, '/appLock');
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Theme'),
            trailing: Switch(
              value: themeProvider.isDarkTheme,
              onChanged: (bool value){
                setState((){
                  themeProvider.toggleTheme();
                });
              }
            ),
          )
        ],
      ),),
    );
  }
}