import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── Dummy account credentials ──
  static const List<Map<String, String>> _dummyUsers = [
    {
      'email': 'john.doe@email.com',
      'password': 'password123',
      'name': 'John Doe',
      'initials': 'JD',
    },
    {
      'email': 'admin@shopnest.com',
      'password': 'admin123',
      'name': 'Admin User',
      'initials': 'AU',
    },
  ];

  Map<String, String>? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  String get userName => _currentUser?['name'] ?? '';
  String get userEmail => _currentUser?['email'] ?? '';
  String get userInitials => _currentUser?['initials'] ?? '';

  /// Returns true on success, false on invalid credentials.
  bool login(String email, String password) {
    try {
      final user = _dummyUsers.firstWhere(
        (u) =>
            u['email'] == email.trim().toLowerCase() &&
            u['password'] == password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
