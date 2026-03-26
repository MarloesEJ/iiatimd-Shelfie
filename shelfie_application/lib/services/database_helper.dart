import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async{
    if(_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT,
        author TEXT,
        isbn TEXT,
        thumbnailUrl TEXT
        description TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  //boek toevoegen
  Future<int> create(Book book) async{
    final db = await instance.database;
    return await db.insert('book', book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //alle boeken ophalen
  Future<List<Book>> readAllBooks() async{
    final db = await instance.database;
    final result = await db.query('books', orderBy: 'createdAt DESC');

    return result.map((json) => Book.fromMap(json)).toList();
  }

  //boek verwijderen
  Future<int> delete(String id) async{
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}