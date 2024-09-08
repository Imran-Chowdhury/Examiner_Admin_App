



import 'package:face_roll_student/core/network/rest_client.dart';
import 'package:face_roll_student/features/search/data/data_source/search_data_source.dart';
import 'package:face_roll_student/features/search/data/data_source/search_data_source_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/search_repository.dart';

final searchRepositoryProvider = Provider((ref) =>
    SearchRepositoryImpl(dataSource: ref.read(searchRepositoryImplProvider)));

class SearchRepositoryImpl implements SearchRepository{
  SearchRepositoryImpl({required this.dataSource});


  SearchDataSource dataSource;
  @override
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async {
    return await dataSource.getAStudent(rollNumber);
  }
}