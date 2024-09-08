abstract class SearchStudentState {
  const SearchStudentState();
}

class SearchStudentInitialState extends SearchStudentState {
  const SearchStudentInitialState();
}

class SearchStudentLoadingState<T> extends SearchStudentState {
  const SearchStudentLoadingState({this.data});

  final T? data;
}

class SearchStudentSuccessState<T> extends SearchStudentState {
  const SearchStudentSuccessState({this.data, this.name});

  final T? data;
  final T? name;
}

class SearchStudentErrorState extends SearchStudentState {
  final String errorMessage;

  const SearchStudentErrorState(this.errorMessage);
}
