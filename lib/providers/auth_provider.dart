import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    final user = await _dbHelper.getUser(username, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      await _dbHelper.insertUser(User(
        username: username,
        password: password,
        isAdmin: false,
        email: email,
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}