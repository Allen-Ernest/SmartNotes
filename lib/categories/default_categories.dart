import 'package:flutter/material.dart';
import 'package:smart_notes/categories/category_model.dart';
import 'package:uuid/uuid.dart';

List<CategoryModel> defaultCategories = [

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'General',
      categoryColor: Colors.grey.value.toRadixString(16),
      categoryIcon: Icons.category.codePoint,
      fontFamily: 'MaterialIcons'),

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'School',
      categoryColor: Colors.purple.value.toRadixString(16),
      categoryIcon: Icons.school.codePoint,
      fontFamily: 'MaterialIcons'
  ),

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'Shopping',
      categoryColor: Colors.pink.value.toRadixString(16),
      categoryIcon: Icons.shopping_cart.codePoint,
      fontFamily: 'MaterialIcons'
  ),

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'Work',
      categoryColor: Colors.yellow.value.toRadixString(16),
      categoryIcon: Icons.work.codePoint,
      fontFamily: 'MaterialIcons'
  ),

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'Personal',
      categoryColor: Colors.blue.value.toRadixString(16),
      categoryIcon: Icons.person.codePoint,
      fontFamily: 'MaterialIcons'
  ),

  CategoryModel(
      categoryId: const Uuid().v4(),
      categoryTitle: 'To do',
      categoryColor: Colors.red.value.toRadixString(16),
      categoryIcon: Icons.task_alt.codePoint,
      fontFamily: 'MaterialIcons'
  ),
];