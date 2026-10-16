import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// What the `/home` route receives: the profile and the real email of the
/// account (the email lives in Auth, not in the profiles table).
class HomeArgs {
  final Profile profile;
  final String email;

  const HomeArgs({required this.profile, required this.email});
}
