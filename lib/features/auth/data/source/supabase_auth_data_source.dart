import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';

/// The only file that uses the Supabase Auth SDK. It turns Supabase
/// responses into [AuthUser] and Supabase errors into [AuthFailure].
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo crear la cuenta.');
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  /// Spanish message for the most common Auth errors.
  String _messageFor(AuthException e) {
    switch (e.code) {
      case 'user_already_exists':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak_password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'email_address_invalid':
        return 'El correo no es válido.';
      default:
        return e.message;
    }
  }
}
