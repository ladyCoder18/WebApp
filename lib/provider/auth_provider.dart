import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool? _isLoggedIn;

  User? get user => _user;
  bool? get isLoggedIn => _isLoggedIn;

  void setUser(User user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
