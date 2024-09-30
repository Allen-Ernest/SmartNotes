import 'package:flutter/material.dart';

class NoteSettings extends StatefulWidget {
  const NoteSettings({super.key});

  @override
  State<NoteSettings> createState() => _NoteSettingsState();
}

class _NoteSettingsState extends State<NoteSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <ListTile>[
            ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Note locking'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Note Categorization'),
                onTap: () {
                  Navigator.pushNamed(context, '/category');
                })
          ],
        ),
      ),
    );
  }
}
