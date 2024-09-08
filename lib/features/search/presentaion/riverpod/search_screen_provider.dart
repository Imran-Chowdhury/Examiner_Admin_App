import 'package:face_roll_student/core/base_state/search_student_state.dart';
import 'package:face_roll_student/features/search/domain/search_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';




// Provider for ProfileNotifier
final searchProvider = StateNotifierProvider<SearchNotifier, SearchStudentState>(
      (ref) => SearchNotifier(useCase: ref.read(searchUseCaseProvider)),
);



// StateNotifier to manage the isEditing state
class SearchNotifier extends StateNotifier<SearchStudentState> {
  SearchNotifier({required this.useCase}) : super(const SearchStudentInitialState());

  SearchUseCase useCase;


  Future<void> getAStudent(String rollNumber) async{
    state = const SearchStudentLoadingState();

    Map<String,dynamic> res = await useCase.getAStudent(rollNumber);
    if (res.containsKey('error')){
      Fluttertoast.showToast(msg: res['error']);
      state = SearchStudentErrorState(res['error']);
    }else{
      state = SearchStudentSuccessState(
        data: [res]
      );
      print(res);

    }

  }

}

