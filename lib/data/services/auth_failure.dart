class AuthFailure implements Exception {
  final String code;
  final String message;
  AuthFailure(this.code, this.message);

  @override
  String toString() => message;
}
