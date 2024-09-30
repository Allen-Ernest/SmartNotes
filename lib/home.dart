import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_page.dart';
import 'package:smart_notes/search/search_page.dart';
import 'package:smart_notes/menu/menuPage.dart';
import 'package:getwidget/getwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> { //TODO: Note Sorting
  int currentIndex = 0;

  void onItemTapped(index) {
    setState(() {
      currentIndex = index;
    });
  }
  void rateApp() async {
    double _rating = 0;
    showDialog(
      context: context,
      builder: (BuildContext context){
        return StatefulBuilder(builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('Enjoying the app, please rate it'),
          content: GFRating(
            value: _rating,
            onChanged: (value){
              setDialogState((){
                _rating = value;
              });
            }
          ),
          actions: <Widget>[
            TextButton(onPressed: (){}, child: const Text('Rate app')),
            TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Rate app')),
          ]
        ));
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const NotePage(),
      const SearchPage(),
      const MenuPage()
    ];
    List appBars = [
      AppBar(title: const Text('My Notes'), actions: <Widget>[
        IconButton(onPressed: (){}, icon: const Icon(Icons.sort))
      ],),
      AppBar(title: const Text('Search')),
      AppBar(title: const Text('Menu')),
    ];
    return Scaffold(
      appBar: appBars[currentIndex],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: pages[currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, '/create_note');
          }, child: const Icon(Icons.add)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Extras'),
        ], onTap: onItemTapped, currentIndex: currentIndex,),
    );
  }
}
