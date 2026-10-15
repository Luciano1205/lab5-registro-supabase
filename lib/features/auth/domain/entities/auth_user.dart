/// What Supabase Auth gives back: the account identity.
///
/// The password is not here: it only travels to Auth.
class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});
}
