/// What the register screen can tell the [RegisterBloc].
abstract class RegisterEvent {}

/// The user filled the form and pressed "Registrarme".
class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String fullName;
  final String email;
  final String password;

  RegisterSubmitted({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
  });
}
