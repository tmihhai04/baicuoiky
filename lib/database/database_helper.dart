import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Lấy đường dẫn thư mục lưu trữ trên thiết bị Android
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'task_manager.db');

    // Tạo hoặc mở cơ sở dữ liệu
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            isAdmin INTEGER,
            email TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            priority TEXT,
            status TEXT,
            dueDate TEXT,
            assignedUserId INTEGER,
            createdById INTEGER,
            attachmentPath TEXT,
            FOREIGN KEY (assignedUserId) REFERENCES users(id),
            FOREIGN KEY (createdById) REFERENCES users(id)
          )
        ''');

        // Thêm dữ liệu mẫu (admin)
        await db.insert('users', {
          'username': 'admin',
          'password': 'admin123',
          'isAdmin': 1,
          'email': 'admin@example.com'
        });
      },
    );
  }

  // User CRUD
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Task CRUD
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks({int? userId, bool isAdmin = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: isAdmin ? null : 'assignedUserId = ?',
      whereArgs: isAdmin ? null : [userId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search and filter
  Future<List<Task>> searchTasks({
    int? userId,
    bool isAdmin = false,
    String? query,
    String? status,
    String? priority,
  }) async {
    final db = await database;
    String whereString = isAdmin ? '' : 'assignedUserId = ?';
    List<dynamic> whereArgs = isAdmin ? [] : [userId];

    if (query != null && query.isNotEmpty) {
      whereString += (whereString.isEmpty ? '' : ' AND ') + 'title LIKE ?';
      whereArgs.add('%$query%');
    }

    if (status != null && status.isNotEmpty) {
      whereString += (whereString.isEmpty ? '' : ' AND ') + 'status = ?';
      whereArgs.add(status);
    }

    if (priority != null && priority.isNotEmpty) {
      whereString += (whereString.isEmpty ? '' : ' AND ') + 'priority = ?';
      whereArgs.add(priority);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}