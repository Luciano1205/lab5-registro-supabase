import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/bloc/home_bloc.dart';
import 'package:moviles_auth/features/home/ui/home_args.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jyhowrpcjpiwonnlaryi.supabase.co',
    publishableKey: 'sb_publishable_T7tHgf9pJJZ4CvDcLShMow_3u5ordr8',
  );
  final client = Supabase.instance.client;
  runApp(
    App(
      auth: AuthRepositoryImpl(SupabaseAuthDataSource(client)),
      profiles: ProfileRepositoryImpl(SupabaseProfileDataSource(client)),
    ),
  );
}

/// Root widget that declares the theme and the named routes.
///
/// It receives the two repositories already built: [main] gives the Supabase
/// ones and the tests give fakes. Each route builds its own Bloc chain on top
/// of them in its [BlocProvider].
class App extends StatelessWidget {
  final AuthRepository auth;
  final ProfileRepository profiles;

  const App({super.key, required this.auth, required this.profiles});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moviles Auth',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => BlocProvider(
          create: (_) => LoginBloc(SignInUseCase(auth, profiles)),
          child: const LoginScreen(),
        ),
        '/register': (_) => BlocProvider(
          create: (_) => RegisterBloc(SignUpUseCase(auth, profiles)),
          child: const RegisterScreen(),
        ),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as HomeArgs;
          return BlocProvider(
            create: (_) => HomeBloc(SignOutUseCase(auth)),
            child: HomeScreen(
              username: args.profile.username,
              fullName: args.profile.fullName,
              email: args.email,
            ),
          );
        },
      },
    );
  }
}
