import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
import '../data/services/auth_failure.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? user;
  String? errorMessage;
  String? errorCode;
  bool loading = false;

  AuthProvider(this._authService) {
    _authService.authChanges.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  void clearError() {
    if (errorMessage != null || errorCode != null) {
      errorMessage = null;
      errorCode = null;
      notifyListeners();
    }
  }

  /// returns true on success (signed in), false on failure
  Future<bool> signIn(String email, String password) async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.signIn(email, password);
      return true;
    } catch (e) {
      if (e is AuthFailure) { errorCode = e.code; errorMessage = e.message; }
      else { errorMessage = e.toString(); }
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }

  /// returns true on success (created+signed in), false on failure
  Future<bool> signUp(String email, String password) async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.signUp(email, password);
      return true;
    } catch (e) {
      if (e is AuthFailure) { errorCode = e.code; errorMessage = e.message; }
      else { errorMessage = e.toString(); }
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }
}
