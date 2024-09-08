

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image/src/image.dart';
import 'package:image/image.dart' as img;
import '../../domain/registration_repository.dart';
import '../data_source/registration_data_source.dart';
import '../data_source/registration_data_source_impl.dart';

final registraionRepositoryProvider = Provider((ref) =>
    RegistrationRepositoryImpl(dataSource: ref.read(registraionDataSourceProvider)));


class RegistrationRepositoryImpl implements RegistrationRepository{
  RegistrationRepositoryImpl({required this.dataSource});
  RegistrationDataSource dataSource;


  @override
  Future<Map<String, dynamic>> createStudent(List<dynamic> embedding, img.Image image, String studentName,
      String rollNumber, String session, String semesterId) async{

    return await dataSource.createStudent(embedding, image, studentName, rollNumber, session, semesterId);
  }

}