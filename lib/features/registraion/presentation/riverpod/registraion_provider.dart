

import 'package:face_roll_student/features/registraion/domain/registration_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;


// Provider for ProfileNotifier
final registrationProvider = StateNotifierProvider<RegistrationNotifier, bool>(
      (ref) => RegistrationNotifier(useCase: ref.read(registraionUseCaseProvider)),
);



// StateNotifier to manage the isEditing state
class RegistrationNotifier extends StateNotifier<bool> {
  RegistrationNotifier({required this.useCase}) : super(false);

  RegistrationUseCase useCase;


  Future<void> createStudent(List<dynamic> embedding, img.Image image, String studentName,
      String rollNumber, String session, String semesterId) async{
    // state = const SearchStudentLoadingState();
    if(embedding.isEmpty){
      Fluttertoast.showToast(
        msg: 'Error occurred while processing image', // Show the first error message
        toastLength: Toast.LENGTH_LONG,
      );
    }

    Map<String, dynamic> responseMap = await useCase.createStudent(embedding, image, studentName, rollNumber, session, semesterId);

    if (responseMap.containsKey('roll_number') && responseMap['roll_number'] is List) {
      // This is likely an error response
      Fluttertoast.showToast(
        msg: responseMap['roll_number'][0], // Show the first error message
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      // This is likely a success response
      Fluttertoast.showToast(
        msg: '${responseMap['name']} has been added successfully!',
        toastLength: Toast.LENGTH_LONG,
      );
    }


  }

}