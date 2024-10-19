import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_page.dart';
import 'package:smart_notes/search/search_page.dart';
import 'package:smart_notes/menu/menuPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/settings/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String groupValue = 'dateCreated';

  void onItemTapped(index) {
    setState(() {
      currentIndex = index;
    });
  }

  void rateApp() async {
    double _rating = 0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) =>
                  AlertDialog(
                      title: const Text('Enjoying the app, please rate it'),
                      content: GFRating(
                          value: _rating,
                          onChanged: (value) {
                            setDialogState(() {
                              _rating = value;
                            });
                          }),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {}, child: const Text('Rate app')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Rate app')),
                      ]));
        });
  }

  Future<void> _launchPlayStore() async {
    final Uri playStoreUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.bytecode.smart_notes.smart_notes'); // Replace with your app's package ID

    if (await canLaunchUrl(playStoreUrl)) {
      await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $playStoreUrl';
    }
  }

  void _loadCategories() async {
    List<CategoryModel> savedCategories =
        await DatabaseHelper().getCategories();
    if (savedCategories.isEmpty) {
      CategoryModel defaultCategory = CategoryModel(
          categoryId: const Uuid().v4(),
          categoryTitle: 'General',
          categoryColor: Colors.grey.value.toRadixString(16),
          categoryIcon: Icons.category.codePoint,
          fontFamily: 'MaterialIcons');

      await DatabaseHelper().insertCategory(defaultCategory);
      savedCategories = await DatabaseHelper().getCategories();
    }
  }

  @override
  void initState() {
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const NotePage(),
      const SearchPage(),
      const MenuPage()
    ];
    List appBars = [
      AppBar(
        title: const Text('My Notes'),
        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.sort, color: Colors.green)
          )
        ],
      ),
      AppBar(title: const Text('Search')),
      AppBar(title: const Text('Menu')),
    ];
    return Scaffold(
      appBar: appBars[currentIndex],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            reverse: currentIndex < pages.indexOf(pages[currentIndex]),
            transitionBuilder: (Widget child,
                Animation<double> primaryAnimation,
                Animation<double> secondaryAnimation) {
              return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child);
            },
            child: pages[currentIndex]),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new note',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.pushNamed(context, '/create_note');
          },
          child: const Icon(Icons.add)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Extras'),
        ],
        onTap: onItemTapped,
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
      ),
    );
  }
}
