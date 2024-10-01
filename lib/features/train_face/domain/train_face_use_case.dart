
import 'package:examiner_admin_app/features/train_face/domain/train_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/repository/train_face_repository_impl.dart';

final trainFaceUseCaseProvider = Provider((ref) {
  return TrainFaceUseCase(repository: ref.read(trainFaceRepositoryProvider));
});

class TrainFaceUseCase {
  TrainFaceUseCase({required this.repository});
  TrainFaceRepository repository;


  Future<List<dynamic>> getImagesList( List trainings, Interpreter interpreter,) async {
    try {
      return  await repository.getOutputList(trainings, interpreter,);

    } catch (e) {
      rethrow;
    }
  }
}
