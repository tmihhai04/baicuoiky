import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks({int? userId, bool isAdmin = false}) async {
    _tasks = await _dbHelper.getTasks(userId: userId, isAdmin: isAdmin);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
    await fetchTasks(
      userId: task.assignedUserId,
      isAdmin: false,
    );
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    await fetchTasks(
      userId: task.assignedUserId,
      isAdmin: false,
    );
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Future<void> searchTasks({
    int? userId,
    bool isAdmin = false,
    String? query,
    String? status,
    String? priority,
  }) async {
    _tasks = await _dbHelper.searchTasks(
      userId: userId,
      isAdmin: isAdmin,
      query: query,
      status: status,
      priority: priority,
    );
    notifyListeners();
  }

  Future<List<User>> getAllUsers() async {
    return await _dbHelper.getAllUsers();
  }
}