import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/base_state.dart';
import '../../domain/train_face_use_case.dart';



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


  Future<List<dynamic>> pickImagesAndTrain(

      Interpreter interpreter,
      List resizedImageList,
      ) async {
    try {
      state = const LoadingState();

      // Check if images are selected
      if (resizedImageList.isEmpty) {
        // print('An error occurred from trainProvider');
        state = const ErrorState('No Face Detected');
        Fluttertoast.showToast(
          msg: 'No Face Detected. Try again!', // Show the first error message
          toastLength: Toast.LENGTH_LONG,
        );

        // Return an empty list if no images are detected
        return [];
      } else {
        // Process and get face embeddings
        List<dynamic> faceEmbeddings = await useCase.getImagesList(


          resizedImageList,
          interpreter,
        );

        // Return the faceEmbeddings list
        return faceEmbeddings;
      }
    } catch (e) {
      // Handle any errors that occur
      // print('An error occurred: $e');
      state = ErrorState(e.toString());

      // Rethrow the error for further handling
      rethrow;
    }
  }

}


