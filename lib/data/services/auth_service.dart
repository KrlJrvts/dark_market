import 'package:firebase_auth/firebase_auth.dart';
import 'auth_failure.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, _mapError(e));
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code, _mapError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'This email already has an account.';
      case 'invalid-email':        return 'Invalid email.';
      case 'weak-password':        return 'Weak password (min 6 chars).';
      case 'user-not-found':       return 'No account found for this email.';
      case 'wrong-password':       return 'Wrong password.';
      default:                     return 'Auth error: ${e.message}';
    }
  }
}
