



import 'package:examiner_admin_app/features/registraion/domain/registration_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../data/repository/registration_repository_impl.dart';


final registraionUseCaseProvider = Provider((ref) {
  return RegistrationUseCase(repository: ref.read(registraionRepositoryProvider));
});

class RegistrationUseCase{
  RegistrationUseCase({required this.repository});
  RegistrationRepository repository;



  Future<Map<String, dynamic>> createStudent(List<dynamic> embedding, img.Image image, String studentName,
      String rollNumber, String session, String semesterId) async{

    return await repository.createStudent(embedding, image, studentName, rollNumber, session, semesterId);
  }
}