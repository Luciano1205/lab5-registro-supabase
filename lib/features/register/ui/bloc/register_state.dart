import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// The moment the register screen is in.
enum RegisterStatus { initial, loading, success, failure }

/// Single state class: the moment is the [status] field, and [copyWith]
/// changes only what is passed.
class RegisterState {
  final RegisterStatus status;
  final Profile? profile;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.profile,
    this.errorMessage,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
