/// What the home screen can tell the [HomeBloc].
abstract class HomeEvent {}

/// The user pressed "Cerrar sesión".
class SignOutRequested extends HomeEvent {}
