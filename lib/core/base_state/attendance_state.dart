abstract class ProfileState {
  const ProfileState();
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState<T> extends ProfileState {
  const ProfileLoadingState({this.data});

  final T? data;
}

class ProfileSuccessState<T> extends ProfileState {
  const ProfileSuccessState({this.data, this.name});

  final T? data;
  final T? name;
}

class ProfileErrorState extends ProfileState {
  final String errorMessage;

  const ProfileErrorState(this.errorMessage);
}
