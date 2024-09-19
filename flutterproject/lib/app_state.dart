import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userDetails;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userDetails => _userDetails;

  void login(Map<String, dynamic> userDetails) {
    _isLoggedIn = true;
    _userDetails = userDetails;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userDetails = null;
    notifyListeners();
  }
}
