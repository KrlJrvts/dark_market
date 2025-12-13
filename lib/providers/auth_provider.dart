import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/services/auth_service.dart';
import '../data/services/auth_failure.dart';
import 'service_providers.dart';

part 'auth_provider.g.dart';

/// State class for authentication
/// This holds all the authentication state data
class AuthState {
  final User? user;
  final String? errorMessage;
  final String? errorCode;
  final bool loading;

  const AuthState({
    this.user,
    this.errorMessage,
    this.errorCode,
    this.loading = false,
  });

  AuthState copyWith({
    User? user,
    String? Function()? errorMessage,
    String? Function()? errorCode,
    bool? loading,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      errorCode: errorCode != null ? errorCode() : this.errorCode,
      loading: loading ?? this.loading,
    );
  }
}

/// Stream provider that listens to Firebase auth state changes
/// This automatically updates when user logs in/out
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authChanges;
}

/// Provider for the current auth state
/// This combines the auth stream with loading/error states
@riverpod
class Auth extends _$Auth {
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  AuthState build() {
    // Listen to auth state changes and update user
    final authStream = ref.watch(authStateChangesProvider);

    return authStream.when(
      data: (user) => AuthState(user: user, loading: false),
      loading: () => const AuthState(loading: true),
      error: (error, _) => AuthState(
        errorMessage: error.toString(),
        loading: false,
      ),
    );
  }

  /// Clear any error messages
  void clearError() {
    if (state.errorMessage != null || state.errorCode != null) {
      state = state.copyWith(
        errorMessage: () => null,
        errorCode: () => null,
      );
    }
  }

  /// Sign in with email and password
  /// Returns true on success, false on failure
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.signIn(email, password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      if (e is AuthFailure) {
        state = state.copyWith(
          errorCode: () => e.code,
          errorMessage: () => e.message,
          loading: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: () => e.toString(),
          loading: false,
        );
      }
      return false;
    }
  }

  /// Sign up with email and password
  /// Returns true on success, false on failure
  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.signUp(email, password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      if (e is AuthFailure) {
        state = state.copyWith(
          errorCode: () => e.code,
          errorMessage: () => e.message,
          loading: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: () => e.toString(),
          loading: false,
        );
      }
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();
    state = state.copyWith(
      errorMessage: () => null,
      errorCode: () => null,
    );
  }

  /// Update user's display name
  Future<bool> updateName(String name) async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.updateDisplayName(name);
      final updatedUser = FirebaseAuth.instance.currentUser;
      state = AuthState(user: updatedUser, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => e.toString(),
        loading: false,
      );
      return false;
    }
  }

  /// Update user's profile photo URL
  Future<bool> updatePhoto(String? url) async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.updatePhotoUrl(url);
      final updatedUser = FirebaseAuth.instance.currentUser;
      state = AuthState(user: updatedUser, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => e.toString(),
        loading: false,
      );
      return false;
    }
  }

  /// Update user's password
  Future<bool> updatePassword(String newPassword, {String? currentPassword}) async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.updatePassword(newPassword, currentPassword: currentPassword);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      String errorMsg;
      if (e.toString().contains('wrong-password')) {
        errorMsg = 'Current password is incorrect';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMsg = 'Please enter your current password';
      } else {
        errorMsg = e.toString();
      }

      state = state.copyWith(
        errorMessage: () => errorMsg,
        loading: false,
      );
      return false;
    }
  }

  /// Delete the current user's account
  Future<bool> deleteAccount() async {
    state = state.copyWith(
      loading: true,
      errorMessage: () => null,
      errorCode: () => null,
    );

    try {
      await _authService.deleteAccount();
      state = const AuthState(user: null, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => e.toString(),
        loading: false,
      );
      return false;
    }
  }
}

/// Helper provider to check if user is logged in
@riverpod
bool isLoggedIn(IsLoggedInRef ref) {
  final authState = ref.watch(authProvider);
  return authState.user != null;
}
