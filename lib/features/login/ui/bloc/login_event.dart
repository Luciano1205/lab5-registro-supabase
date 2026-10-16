/// What the login screen can tell the [LoginBloc].
abstract class LoginEvent {}

/// The user filled the form and pressed "Iniciar sesión".
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}
