import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _userId = '';

  String get name => _name;
  String get userId => _userId;

  void setUser({
    required String name,
    required String userId,
  }) {
    _name = name;
    _userId = userId;
    notifyListeners();
  }

  void clearUser() {
    _name = '';
    _userId = '';
    notifyListeners();
  }
}