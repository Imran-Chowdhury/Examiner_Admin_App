



import 'package:dartz/dartz.dart';
import 'package:face_roll_student/features/search/domain/search_repository.dart';
// import 'package:examiner_admin_app/features/search/domain/search_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/search_repository_impl.dart';

final searchUseCaseProvider = Provider((ref) {
  return SearchUseCase(repository: ref.read(searchRepositoryProvider));
});


class SearchUseCase{
  SearchUseCase({required this.repository});
  SearchRepository repository;
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async{

    return await repository.getAStudent(rollNumber);
  }

  Future<Either<Map<String, dynamic>, List>> getStudentBySemester(String semester) async{


    return await repository.getStudentBySemester(semester);
  }
}