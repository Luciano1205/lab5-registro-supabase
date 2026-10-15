import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Registers a user. It is the only piece that knows registering is two
/// steps, and it decides their order: first the account, then the profile
/// with the id that Auth returned.
class SignUpUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignUpUseCase(this._auth, this._profiles);

  Future<Profile> call({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    // 1. The account. If it fails, nothing was created and the error goes up.
    final user = await _auth.signUp(email: email, password: password);

    // 2. The profile, with the id of the account.
    final profile = Profile(
      id: user.id,
      username: username,
      fullName: fullName,
    );
    try {
      await _profiles.createProfile(profile);
    } on Exception {
      // The account exists but has no profile: close the session it opened
      // and report a domain error.
      try {
        await _auth.signOut();
      } on Exception {
        // Nothing else to do: the original problem is the profile.
      }
      throw const AuthFailure(
        'Tu cuenta se creó, pero no se pudo guardar tu perfil. '
        'Intenta de nuevo más tarde.',
      );
    }
    return profile;
  }
}
