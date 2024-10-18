import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smart_notes/settings/category_model.dart';
import 'package:smart_notes/notes/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper(){
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_notebook_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE note_categories(
    categoryId TEXT PRIMARY KEY,
    categoryTitle TEXT,
    categoryColor,
    categoryIcon, 
    fontFamily)
    ''');

    await db.execute(''' 
    CREATE TABLE notes(noteId TEXT PRIMARY KEY,
    noteTitle TEXT,
    noteType TEXT,
    noteContent TEXT,
    dateCreated TEXT,
    hasReminder INTEGER,
    isBookmarked INTEGER,
    isLocked INTEGER,
    reminderTime TEXT)
    ''');
  }

  Future<int> insertCategory(CategoryModel category) async {
    Database db = await database;
    return await db.insert('note_categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryModel>> getCategories() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('note_categories');

    return List.generate(maps.length, (i){
      return CategoryModel.fromJson(maps[i]);
    });
  }

  Future<int> updateCategory(CategoryModel category) async {
    Database db = await database;
    return await db.update('note_categories', category.toJson(), where: 'categoryId = ?', whereArgs: [category.categoryId]);
  }

  Future<int> deleteCategory(String categoryId) async {
    Database db = await database;
    return await db.delete(
        'note_categories',
      where: 'categoryId = ?', whereArgs: [categoryId]
    );
  }

  Future<int> insertNote(NoteModel note) async {
    Database db = await database;
    return await db.insert('notes', note.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NoteModel>> getNotes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');

    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }

  Future<int> updateNote(NoteModel note) async {
    Database db = await database;
    return await db.update('notes', note.toJson(), where: 'noteId = ?', whereArgs: [note.noteId]);
  }

  Future<int> deleteNote(String noteId) async {
    Database db = await database;
    return await db.delete('notes', where: 'noteId = ?', whereArgs: [noteId]);
  }
}