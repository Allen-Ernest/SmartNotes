import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_page.dart';
import 'package:smart_notes/search/search_page.dart';
import 'package:smart_notes/menu/menuPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/categories/category_model.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_notes/categories/default_categories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String sortingMode = 'dateCreated-ascending';
  int maxIgnoredPrompts = 3;
  int ignoredCount = 0;

  void getSortingOption() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sortingMode = sharedPreferences.getString('sortingMode');
    setState(() {
      sortingMode = sortingMode ?? 'dateCreated-ascending';
    });
  }

  void onItemTapped(index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _checkAndShowRatingDialog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool hasRated = preferences.getBool('hasRated') ?? false;
    ignoredCount = preferences.getInt('ignoredCount') ?? 0;

    if (!hasRated && ignoredCount < maxIgnoredPrompts){
      Future.delayed(const Duration(seconds: 3), (){
        rateApp();
      });
    }
  }

  void rateApp() async {
    double rating = 0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) =>
                  AlertDialog(
                      title: const Text('Enjoying the app, please rate it'),
                      content: GFRating(
                        color: Colors.green,
                          borderColor: Colors.green,
                          value: rating,
                          onChanged: (value) {
                            setDialogState(() {
                              rating = value;
                            });
                          }),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () async {
                              if (rating > 0){
                                await _launchPlayStore();
                                _markAsRated();
                              } else {
                                _incrementIgnoreCount();
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text('Rate app', style: TextStyle(color: Colors.green))),
                        TextButton(
                            onPressed: () {
                              _incrementIgnoreCount();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Maybe later', style: TextStyle(color: Colors.green))),
                      ]));
        });
  }

  void _incrementIgnoreCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ignoredCount = prefs.getInt('ignoredCount') ?? 0;
    ignoredCount++;
    prefs.setInt('ignoredCount', ignoredCount);
  }

  void _markAsRated() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('hasRated', true);
  }

  Future<void> _launchPlayStore() async {
    final Uri playStoreUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.bytecode.smart_notes.smart_notes');

    if (await canLaunchUrl(playStoreUrl)) {
      await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $playStoreUrl';
    }
  }

  void _loadCategories() async {
    List<CategoryModel> savedCategories =
        await DatabaseHelper().getCategories();
    if (savedCategories.isEmpty){
      for (var category in defaultCategories){
        await DatabaseHelper().insertCategory(category);
      }
      savedCategories = await DatabaseHelper().getCategories();
    }
  }


  @override
  void initState() {
    _loadCategories();
    _checkAndShowRatingDialog();
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
