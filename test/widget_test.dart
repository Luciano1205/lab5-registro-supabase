import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/main.dart';

const _password = '123456';

/// Auth without Supabase: one account with a fixed id and password.
class FakeAuthRepository implements AuthRepository {
  bool signedOut = false;

  @override
  Future<AuthUser> signUp({required String email, required String password}) async {
    return AuthUser(id: 'uid-123', email: email);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    if (password != _password) {
      throw const AuthFailure('Correo o contraseña incorrectos.');
    }
    return AuthUser(id: 'uid-123', email: email);
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

/// Profiles without Supabase: kept in memory, or failing on purpose.
class FakeProfileRepository implements ProfileRepository {
  final bool fail;
  final Map<String, Profile> rows = {};

  FakeProfileRepository({this.fail = false});

  @override
  Future<void> createProfile(Profile profile) async {
    if (fail) throw const AuthFailure('permission denied for table profiles');
    rows[profile.id] = profile;
  }

  @override
  Future<Profile> getProfile(String id) async {
    final row = rows[id];
    if (fail || row == null) throw const AuthFailure('Esta cuenta no tiene perfil.');
    return row;
  }
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> goToRegister(WidgetTester tester) async {
  await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
  await tester.pumpAndSettle();
  expect(find.text('Crea tu cuenta'), findsOneWidget);
}

Future<void> fillRegisterForm(WidgetTester tester, {String confirm = _password}) async {
  await tester.enterText(find.byType(TextField).at(0), 'ana');
  await tester.enterText(find.byType(TextField).at(1), 'Ana Gómez');
  await tester.enterText(find.byType(TextField).at(2), 'ana@icesi.edu.co');
  await tester.enterText(find.byType(TextField).at(3), _password);
  await tester.enterText(find.byType(TextField).at(4), confirm);
}

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
  });

  group('Login', () {
    testWidgets('asks for both fields before calling the Bloc', (tester) async {
      await tester.pumpWidget(App(auth: auth, profiles: profiles));
      await tapButton(tester, 'Iniciar sesión');
      expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);
    });

    testWidgets('shows the error when the password is wrong', (tester) async {
      profiles.rows['uid-123'] =
          const Profile(id: 'uid-123', username: 'ana', fullName: 'Ana Gómez');
      await tester.pumpWidget(App(auth: auth, profiles: profiles));

      await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
      await tester.enterText(find.byType(TextField).at(1), 'otra');
      await tapButton(tester, 'Iniciar sesión');

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    });

    testWidgets('opens the profile with the real email and signs out', (
      tester,
    ) async {
      profiles.rows['uid-123'] =
          const Profile(id: 'uid-123', username: 'ana', fullName: 'Ana Gómez');
      await tester.pumpWidget(App(auth: auth, profiles: profiles));

      await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
      await tester.enterText(find.byType(TextField).at(1), _password);
      await tapButton(tester, 'Iniciar sesión');

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('@ana'), findsOneWidget);
      expect(find.text('ana@icesi.edu.co'), findsOneWidget);

      await tapButton(tester, 'Cerrar sesión');
      expect(auth.signedOut, isTrue);
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    });

    testWidgets('closes the session if the account has no profile', (
      tester,
    ) async {
      await tester.pumpWidget(App(auth: auth, profiles: profiles));

      await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
      await tester.enterText(find.byType(TextField).at(1), _password);
      await tapButton(tester, 'Iniciar sesión');

      expect(auth.signedOut, isTrue);
      expect(find.textContaining('No se pudo cargar tu perfil'), findsOneWidget);
    });
  });

  group('Register', () {
    testWidgets('rejects passwords that do not match', (tester) async {
      await tester.pumpWidget(App(auth: auth, profiles: profiles));
      await goToRegister(tester);

      await fillRegisterForm(tester, confirm: '654321');
      await tapButton(tester, 'Registrarme');

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
      expect(profiles.rows, isEmpty);
    });

    testWidgets('saves the profile with the Auth id and shows it', (
      tester,
    ) async {
      await tester.pumpWidget(App(auth: auth, profiles: profiles));
      await goToRegister(tester);

      await fillRegisterForm(tester);
      await tapButton(tester, 'Registrarme');

      expect(profiles.rows['uid-123']?.username, 'ana');
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('@ana'), findsOneWidget);
      expect(find.text('ana@icesi.edu.co'), findsOneWidget);
    });

    testWidgets('if the profile fails, closes the session and shows an error', (
      tester,
    ) async {
      final failing = FakeProfileRepository(fail: true);
      await tester.pumpWidget(App(auth: auth, profiles: failing));
      await goToRegister(tester);

      await fillRegisterForm(tester);
      await tapButton(tester, 'Registrarme');

      expect(auth.signedOut, isTrue);
      expect(find.textContaining('no se pudo guardar tu perfil'), findsOneWidget);
    });
  });
}
