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

  Future<bool> updateName(String name) async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.updateDisplayName(name);
      user = FirebaseAuth.instance.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }

  // url is optional – if you never upload, you simply never call this
  Future<bool> updatePhoto(String? url) async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.updatePhotoUrl(url);
      user = FirebaseAuth.instance.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    loading = true; errorMessage = null; errorCode = null; notifyListeners();
    try {
      await _authService.deleteAccount();
      user = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false; notifyListeners();
    }
  }
}
