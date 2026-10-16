import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/home/ui/bloc/home_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/home_state.dart';

/// Closes the session through [SignOutUseCase] so the screen never talks to
/// the domain directly.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SignOutUseCase _signOut;

  HomeBloc(this._signOut) : super(const HomeState()) {
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _signOut();
      emit(state.copyWith(status: HomeStatus.signedOut));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
