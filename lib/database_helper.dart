import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'searched_books.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE searched_books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, imageLink TEXT)');
  }

  Future<void> insertBook(Map<String, dynamic> book) async {
    Database db = await instance.database;
    await db.insert('searched_books', book,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> clearHistory() async {
    Database db = await instance.database;
    await db.delete('searched_books');
  }

  Future<List<Map<String, dynamic>>> getRecentBooks() async {
    Database db = await instance.database;
    return await db.query('searched_books', orderBy: 'id DESC', limit: 10);
  }
}
