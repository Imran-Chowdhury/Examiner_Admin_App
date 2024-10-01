



import 'package:dartz/dartz.dart';
// import 'package:examiner_admin_app/features/search/data/data_source/search_data_source.dart';
import 'package:face_roll_student/features/search/data/data_source/search_data_source.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/rest_client.dart';


final searchRepositoryImplProvider = Provider((ref) =>
    SearchDataSourceImpl(restClient: ref.read(restClientProvider)));


class SearchDataSourceImpl implements SearchDataSource{
  SearchDataSourceImpl({required this.restClient});
  RestClient restClient;
  @override
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async {
   return await restClient.getAStudent(rollNumber);
  }

  @override
  Future<Either<Map<String, dynamic>, List>> getStudentBySemester(String semester)async {
    return await restClient.getStudentBySemester(semester);
  }

}