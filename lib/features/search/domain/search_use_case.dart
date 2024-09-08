



import 'package:face_roll_student/features/search/data/repository/search_repository_impl.dart';
import 'package:face_roll_student/features/search/domain/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchUseCaseProvider = Provider((ref) {
  return SearchUseCase(repository: ref.read(searchRepositoryProvider));
});


class SearchUseCase{
  SearchUseCase({required this.repository});
  SearchRepository repository;
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async{

    return await repository.getAStudent(rollNumber);
  }
}