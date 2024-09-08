



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

}