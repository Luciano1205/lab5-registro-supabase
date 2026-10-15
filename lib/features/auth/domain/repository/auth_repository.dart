import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// What the domain needs from the authentication service.
///
/// It says what can be asked, not who does it.
abstract class AuthRepository {
  /// Creates the account and returns its identity.
  Future<AuthUser> signUp({
    required String email,
    required String password,
  });

  /// Closes the current session.
  Future<void> signOut();
}
