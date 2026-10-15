import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/main.dart';

/// Auth without Supabase: always creates the account with a fixed id.
class FakeAuthRepository implements AuthRepository {
  bool signedOut = false;

  @override
  Future<AuthUser> signUp({required String email, required String password}) async {
    return AuthUser(id: 'uid-123', email: email);
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

/// Profiles without Supabase: saves in memory or fails on purpose.
class FakeProfileRepository implements ProfileRepository {
  final bool fail;
  Profile? saved;

  FakeProfileRepository({this.fail = false});

  @override
  Future<void> createProfile(Profile profile) async {
    if (fail) throw const AuthFailure('permission denied for table profiles');
    saved = profile;
  }
}

/// The register flow wired to the fakes instead of Supabase.
Widget registerApp(AuthRepository auth, ProfileRepository profiles) {
  return MaterialApp(
    initialRoute: '/register',
    routes: {
      '/register': (_) => BlocProvider(
        create: (_) => RegisterBloc(SignUpUseCase(auth, profiles)),
        child: const RegisterScreen(),
      ),
      '/home': (context) {
        final profile = ModalRoute.of(context)!.settings.arguments as Profile;
        return HomeScreen(
          username: profile.username,
          fullName: profile.fullName,
        );
      },
    },
  );
}

Future<void> fillRegisterForm(WidgetTester tester, {String confirm = '123456'}) async {
  await tester.enterText(find.byType(TextField).at(0), 'ana');
  await tester.enterText(find.byType(TextField).at(1), 'Ana Gómez');
  await tester.enterText(find.byType(TextField).at(2), 'ana@icesi.edu.co');
  await tester.enterText(find.byType(TextField).at(3), '123456');
  await tester.enterText(find.byType(TextField).at(4), confirm);
}

Future<void> tapRegister(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Registrarme');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign in goes to profile and sign out comes back', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();
    expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('sign up rejects passwords that do not match', (tester) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await tester.pumpWidget(registerApp(auth, profiles));

    await fillRegisterForm(tester, confirm: '654321');
    await tapRegister(tester);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(profiles.saved, isNull);
  });

  testWidgets('sign up saves the profile with the Auth id and shows it', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await tester.pumpWidget(registerApp(auth, profiles));

    await fillRegisterForm(tester);
    await tapRegister(tester);

    expect(profiles.saved?.id, 'uid-123');
    expect(profiles.saved?.username, 'ana');
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('@ana'), findsOneWidget);
  });

  testWidgets('if the profile fails, the session is closed and an error shown', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository(fail: true);
    await tester.pumpWidget(registerApp(auth, profiles));

    await fillRegisterForm(tester);
    await tapRegister(tester);

    expect(auth.signedOut, isTrue);
    expect(find.textContaining('no se pudo guardar tu perfil'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
  });
}
