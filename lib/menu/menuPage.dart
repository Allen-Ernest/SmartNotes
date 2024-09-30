import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <ListTile>[
        ListTile(
          leading: const Icon(Icons.alarm),
          title: const Text('Reminders'),
          onTap: (){
            Navigator.pushNamed(context, '/reminders');
          },
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Bookmarks'),
          onTap: (){
            Navigator.pushNamed(context, '/bookmarks');
          },
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: const Text('Exports'),
          onTap: (){
            Navigator.pushNamed(context, '/exports');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: (){
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}
