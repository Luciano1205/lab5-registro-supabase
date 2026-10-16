import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// What the domain needs from the profiles storage.
abstract class ProfileRepository {
  /// Saves the profile of an account that already exists.
  Future<void> createProfile(Profile profile);

  /// Reads the profile whose id is the account id.
  Future<Profile> getProfile(String id);
}
