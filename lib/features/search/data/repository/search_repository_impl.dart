



import 'package:face_roll_student/core/network/rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/search_repository.dart';

final searchRepositoryProvider = Provider((ref) =>
    SearchRepositoryImpl(restClient: ref.read(restClientProvider)));

class SearchRepositoryImpl implements SearchRepository{
  SearchRepositoryImpl({required this.restClient});

  RestClient restClient;
  @override
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async {
    return await restClient.getAStudent(rollNumber);
  }
}