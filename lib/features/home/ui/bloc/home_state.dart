/// The moment the home screen is in.
enum HomeStatus { initial, loading, signedOut, failure }

/// Single state class with [copyWith], like the other screens.
class HomeState {
  final HomeStatus status;
  final String? errorMessage;

  const HomeState({this.status = HomeStatus.initial, this.errorMessage});

  HomeState copyWith({HomeStatus? status, String? errorMessage}) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
