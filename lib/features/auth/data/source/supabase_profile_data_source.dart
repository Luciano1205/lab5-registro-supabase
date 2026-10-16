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

  Future<Profile> getProfile(String id) async {
    try {
      final row = await _client.from('profiles').select().eq('id', id).single();
      return Profile(
        id: row['id'] as String,
        username: row['username'] as String,
        fullName: row['full_name'] as String,
      );
    } on PostgrestException catch (e) {
      // PGRST116: .single() found no row.
      if (e.code == 'PGRST116') {
        throw const AuthFailure('Esta cuenta no tiene perfil.');
      }
      throw AuthFailure(e.message);
    }
  }
}
