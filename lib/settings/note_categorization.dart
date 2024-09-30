import 'package:flutter/material.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import 'package:smart_notes/settings/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_notes/database/database_helper.dart';

class NoteCategorizationPage extends StatefulWidget {
  const NoteCategorizationPage({super.key});

  @override
  State<NoteCategorizationPage> createState() => _NoteCategorizationPageState();
}

class _NoteCategorizationPageState extends State<NoteCategorizationPage> {
  TextEditingController controller = TextEditingController();
  IconData? iconData;
  Color? themeColor;
  String? fontFamily;
  List<CategoryModel> categories = [];

  void _pickIcon() async {
    IconData? icon =
        await FlutterIconPicker.showIconPicker(context, iconPackModes: [
      IconPack.lineAwesomeIcons,
      IconPack.material,
      IconPack.fontAwesomeIcons,
      IconPack.cupertino
    ]);
    if (icon != null) {
      setState(() {
        iconData = icon;
        fontFamily = icon.fontFamily ?? 'MaterialIcons';
      });
    }
  }

  void _pickTheme() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Pick Category Theme')]),
              content: ListView(children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.blue),
                    title: const Text('Blue'),
                    tileColor: Colors.blue.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.blue;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.blueAccent),
                    title: const Text('Blue Accent'),
                    tileColor: Colors.blueAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.blueAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.lightBlue),
                    title: const Text('Light Blue'),
                    tileColor: Colors.lightBlue.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.lightBlue;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category,
                        color: Colors.lightBlueAccent),
                    title: const Text('Light Blue Accent'),
                    tileColor: Colors.lightBlueAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.lightBlueAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.green),
                    title: const Text('Green'),
                    tileColor: Colors.green.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.green;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.greenAccent),
                    title: const Text('Green Accent'),
                    tileColor: Colors.greenAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.greenAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.red),
                    title: const Text('Red'),
                    tileColor: Colors.red.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.red;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.redAccent),
                    title: const Text('Red Accent'),
                    tileColor: Colors.redAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.red;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.amber),
                    title: const Text('Amber'),
                    tileColor: Colors.amber.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.amber;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.amberAccent),
                    title: const Text('Amber Accent'),
                    tileColor: Colors.amberAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.amberAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.yellow),
                    title: const Text('Yellow'),
                    tileColor: Colors.yellow.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.yellow;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.yellowAccent),
                    title: const Text('Yellow Accent'),
                    tileColor: Colors.yellowAccent.withOpacity(0.1),
                    onTap: () {
                      themeColor = Colors.yellowAccent;
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.pink),
                    title: const Text('Pink'),
                    tileColor: Colors.pink.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.pink;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.pinkAccent),
                    title: const Text('PinkAccent'),
                    tileColor: Colors.pinkAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.pinkAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.purple),
                    title: const Text('Purple'),
                    tileColor: Colors.purple.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.purple;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.purpleAccent),
                    title: const Text('Purple Accent'),
                    tileColor: Colors.purpleAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.purpleAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.deepPurple),
                    title: const Text('Deep purple'),
                    tileColor: Colors.deepPurple.withOpacity(0.1),
                    onTap: () {
                      themeColor = Colors.deepPurple;
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category,
                        color: Colors.deepPurpleAccent),
                    title: const Text('Deep purple Accent'),
                    tileColor: Colors.deepPurpleAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.deepPurpleAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.blueGrey),
                    title: const Text('Blue Grey'),
                    tileColor: Colors.blueGrey.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.blueGrey;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.grey),
                    title: const Text('Grey'),
                    tileColor: Colors.grey.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.grey;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.brown),
                    title: const Text('Brown'),
                    tileColor: Colors.brown.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.brown;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.orange),
                    title: const Text('Orange'),
                    tileColor: Colors.orange.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.orange;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.orangeAccent),
                    title: const Text('Orange Accent'),
                    tileColor: Colors.orangeAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.orangeAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.deepOrange),
                    title: const Text('Deep Orange'),
                    tileColor: Colors.deepOrange.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.deepOrange;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category,
                        color: Colors.deepOrangeAccent),
                    title: const Text('Deep Orange Accent'),
                    tileColor: Colors.deepOrange.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.deepOrangeAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.cyan),
                    title: const Text('Cyan'),
                    tileColor: Colors.cyan.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.cyan;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.cyanAccent),
                    title: const Text('Cyan Accent'),
                    tileColor: Colors.cyanAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.cyanAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.lightGreen),
                    title: const Text('Light Green'),
                    tileColor: Colors.lightGreen.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.lightGreen;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category,
                        color: Colors.lightGreenAccent),
                    title: const Text('Light Green Accent'),
                    tileColor: Colors.lightGreenAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.lightGreenAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.lime),
                    title: const Text('Lime'),
                    tileColor: Colors.lime.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.lime;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.limeAccent),
                    title: const Text('Lime Accent'),
                    tileColor: Colors.limeAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.limeAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.indigo),
                    title: const Text('Indigo'),
                    tileColor: Colors.indigo.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.indigo;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.indigoAccent),
                    title: const Text('Indigo Accent'),
                    tileColor: Colors.indigoAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.indigoAccent;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: const Icon(Icons.category, color: Colors.teal),
                    title: const Text('Teal'),
                    tileColor: Colors.teal.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.teal;
                      });
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.tealAccent),
                    title: const Text('Teal Accent'),
                    tileColor: Colors.tealAccent.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        themeColor = Colors.tealAccent;
                      });
                      Navigator.of(context).pop();
                    }),
              ]),
            ));
  }

  void _loadCategories() async {
    List<CategoryModel> savedCategories =
        await DatabaseHelper().getCategories();
    setState(() {
      categories = savedCategories;
    });
  }

  void _deleteCategory(CategoryModel category) async {
    await DatabaseHelper().deleteCategory(category.categoryId);
    setState(() {
      categories.remove(category);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed category ${category.categoryTitle}')));
  }

  void _addCategory() async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a category name')));
      return;
    }
    if (iconData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a category icon')));
      return;
    }
    if (themeColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a category theme')));
      return;
    }
    String categoryId = const Uuid().v4();
    String colorHex = themeColor!.value.toRadixString(16);
    int iconCodePoint = iconData!.codePoint;
    final CategoryModel newCategory = CategoryModel(
        categoryId: categoryId,
        categoryTitle: controller.text.trim(),
        categoryColor: colorHex,
        categoryIcon: iconCodePoint,
        fontFamily: fontFamily ?? 'MaterialIcons');

    await DatabaseHelper().insertCategory(newCategory);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('New category added ${controller.text.trim()}')));
    _loadCategories();
  }

  @override
  initState() {
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorize Your Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                  onPressed: _pickIcon,
                  child: Icon(iconData ?? Icons.category)),
              ElevatedButton(
                  onPressed: _pickTheme,
                  child: Icon(
                    Icons.palette,
                    color: themeColor,
                  )),
            ]),
            ElevatedButton(
                onPressed: () {
                  _addCategory();
                },
                child: const Text("Add category")),
            Expanded(
              child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    if (categories.isNotEmpty) {
                      CategoryModel category = categories[index];
                      IconData iconData = IconData(category.categoryIcon,
                          fontFamily: 'MaterialIcons');
                      Color color =
                          Color(int.parse(category.categoryColor, radix: 16));
                      return ListTile(
                          leading: Icon(iconData, color: color),
                          title: Text(category.categoryTitle),
                          subtitle: Text('${category.categoryTitle} note'),
                          tileColor: color.withOpacity(0.1),
                          trailing: IconButton(
                              onPressed: () {
                                _deleteCategory(category);
                              },
                              icon: const Icon(Icons.delete)));
                    } else {
                      return const Text('You have no note categories created');
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}

//TODO: There should be default category to handle notes with no category or notes with deleted categories
//TODO: Add tile color property and icon color property to list tile of the list view builder
