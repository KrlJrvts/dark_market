import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? user;
  String? _error;
  bool loading = false;

  AuthProvider(this._authService) {
    _authService.authChanges.listen((user) {
      user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    loading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    loading = true;
    _error = null;
    try {
      await _authService.signUp(email, password);
    } catch (e) {
      _error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
  Future<void> signOut() => _authService.signOut();
}
