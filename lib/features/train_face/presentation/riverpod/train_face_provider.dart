import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/base_state.dart';
import '../../domain/train_face_use_case.dart';

// final trainFaceProvider = StateNotifierProvider<TrainFaceNotifier, BaseState>(
//   (ref) {
//     return TrainFaceNotifier(
//         ref: ref, useCase: ref.read(trainFaceUseCaseProvider));
//   },
// );

final trainFaceProvider = StateNotifierProvider.family(
  (ref, family) {
    return TrainFaceNotifier(
        ref: ref, useCase: ref.read(trainFaceUseCaseProvider));
  },
);

class TrainFaceNotifier extends StateNotifier<BaseState> {
  final Ref ref;
  final TrainFaceUseCase useCase;

  TrainFaceNotifier({
    required this.ref,
    required this.useCase,
  }) : super(const InitialState());

  Future<void> pickImagesAndTrain(
      String name,
      String rollNumber,
      String session,
      String semester,
      Interpreter interpreter,
      List resizedImageList,
      String nameOfJsonFile,
      ) async {
    try {
      state = const LoadingState();

      // Check if images are selected
      if (resizedImageList.isEmpty) {
        print('An error occurred from trainProvider');
        state = const ErrorState('No Face Detected');
        Fluttertoast.showToast(
          msg: 'No Face Detected. Try again!', // Show the first error message
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        // Process the images
        Map<String, dynamic> responseMap = await useCase.getImagesList(
          name,
          rollNumber,
          session,
          semester,
          resizedImageList,
          interpreter,
          nameOfJsonFile,
        );

        print(responseMap);

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
    } catch (e) {
      rethrow;
    }
  }
}


// class TrainFaceNotifier extends StateNotifier<BaseState> {
//   Ref ref;
//   TrainFaceUseCase useCase;
//
//   TrainFaceNotifier({required this.ref, required this.useCase})
//       : super(const InitialState());
//
//   Future<void> pickImagesAndTrain(String name, String rollNumber, String session, String semester,
//       Interpreter interpreter,
//       List resizedImageList, String nameOfJsonFile) async {
//     try {
//       state = const LoadingState();
//       // Selecting single or multiple images for training
//       if (resizedImageList.isEmpty) {
//         print('An error ocured from trainProvider');
//         state = const ErrorState('No Face Detected');
//       } else {
//      Map<String,dynamic> responseMap =  await useCase.getImagesList(
//             name,rollNumber, session, semester, resizedImageList, interpreter, nameOfJsonFile);
//         // state = SuccessState(name: name);
//         print(responseMap);
//          if (responseMap.containsKey('roll_number') && responseMap['roll_number'] is List) {
//            // This is likely an error response
//            Fluttertoast.showToast(
//              msg: responseMap['roll_number'][0],  // Show the first error message
//              toastLength: Toast.LENGTH_SHORT,
//            );
//          } else {
//            // This is likely a success response
//            Fluttertoast.showToast(
//              msg: '${responseMap['name']} has been added successfully!',
//              toastLength: Toast.LENGTH_SHORT,
//            );
//          }
//       }
//       // await useCase.getImagesList(name, resizedImageList, interpreter, nameOfJsonFile);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
