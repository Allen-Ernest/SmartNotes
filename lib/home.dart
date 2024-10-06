import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_page.dart';
import 'package:smart_notes/search/search_page.dart';
import 'package:smart_notes/menu/menuPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/settings/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String groupValue = 'dateCreated';

  final StreamController<String> _sortingStreamController =
      StreamController<String>.broadcast();

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

  void sortNotes() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    showModalBottomSheet(
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return ListView(children: <Widget>[
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Sort Notes')]),
            RadioListTile(
                title: const Text('Date Created'),
                groupValue: groupValue,
                value: 'dateCreated',
                onChanged: (value) {
                  setState(() {
                    groupValue = value!;
                  });
                  preferences.setString('sortingOption', value!);
                  _sortingStreamController.add(groupValue);
                  Navigator.of(context).pop();
                }),
            RadioListTile(
              title: const Text('Alphabetic'),
              groupValue: groupValue,
              value: 'alphabetic',
              onChanged: (value) {
                setState(() {
                  groupValue = value!;
                });
                preferences.setString('sortingOption', value!);
                _sortingStreamController.add(groupValue);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile(
              title: const Text('Category'),
              groupValue: groupValue,
              value: 'category',
              onChanged: (value) {
                setState(() {
                  groupValue = value!;
                });
                preferences.setString('sortingOption', value!);
                _sortingStreamController.add(groupValue);
                Navigator.of(context).pop();
              },
            ),
          ]);
        });
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

  void _loadSortingOption() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? sortingOption = preferences.getString('sortingOption');
    if (sortingOption != null) {
      setState(() {
        groupValue = sortingOption;
      });
    }
  }

  @override
  void dispose() {
    _sortingStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    _loadSortingOption();
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      NotePage(sortingStream: _sortingStreamController.stream),
      const SearchPage(),
      const MenuPage()
    ];
    List appBars = [
      AppBar(
        title: const Text('My Notes'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                sortNotes();
              },
              icon: const Icon(
                Icons.sort,
                color: Colors.green,
              ))
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
