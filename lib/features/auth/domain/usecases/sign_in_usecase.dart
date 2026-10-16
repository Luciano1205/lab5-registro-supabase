import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Signs a user in. Also two steps, in order: open the session, then read
/// the profile with the id that Auth returned.
class SignInUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignInUseCase(this._auth, this._profiles);

  Future<({AuthUser user, Profile profile})> call({
    required String email,
    required String password,
  }) async {
    // 1. The session. If it fails, nothing was opened and the error goes up.
    final user = await _auth.signIn(email: email, password: password);

    // 2. The profile of that account.
    try {
      final profile = await _profiles.getProfile(user.id);
      return (user: user, profile: profile);
    } on Exception {
      // Without a profile the app can't continue: close the session it
      // just opened and report a domain error.
      try {
        await _auth.signOut();
      } on Exception {
        // Nothing else to do: the original problem is the profile.
      }
      throw const AuthFailure('No se pudo cargar tu perfil. Intenta de nuevo.');
    }
  }
}
