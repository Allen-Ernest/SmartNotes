import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../bookmarks/bookmarksPage.dart';
import '../exports/exportsPage.dart';
import '../notifications/reminders_page.dart';
import '../settings/settingsPage.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <ListTile>[
        ListTile(
          leading: const Icon(Icons.alarm),
          title: const Text('Reminders'),
          onTap: () {
            _navigateWithTransition(context, '/reminders');
          },
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Bookmarks'),
          onTap: () {
            _navigateWithTransition(context, '/bookmarks');
          },
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: const Text('Exports'),
          onTap: () {
            _navigateWithTransition(context, '/exports');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            _navigateWithTransition(context, '/settings');
          },
        ),
      ],
    );
  }

  void _navigateWithTransition(BuildContext context, String routeName) {
    Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _getPageByRoute(routeName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        }));
  }

  Widget _getPageByRoute(String routeName) {
    switch (routeName) {
      case '/reminders':
        return const RemindersPage();
      case '/bookmarks':
        return const BookmarksPage();
      case '/exports':
        return const ExportsPage();
      case '/settings':
        return const SettingsPage();
      default:
        return const Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
