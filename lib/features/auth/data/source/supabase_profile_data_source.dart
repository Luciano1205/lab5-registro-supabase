import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';

/// The only file that talks to the `profiles` table. It is also the only one
/// that knows the Dart field `fullName` is the column `full_name`.
class SupabaseProfileDataSource {
  final SupabaseClient _client;

  SupabaseProfileDataSource(this._client);

  Future<void> createProfile(Profile profile) async {
    try {
      await _client.from('profiles').insert({
        'id': profile.id,
        'username': profile.username,
        'full_name': profile.fullName,
      });
    } on PostgrestException catch (e) {
      throw AuthFailure(e.message);
    }
  }
}
