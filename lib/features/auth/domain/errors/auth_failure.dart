/// Domain error for anything that goes wrong while authenticating.
///
/// [toString] returns only [message], so the Bloc can show it as is.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}
