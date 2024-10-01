



import 'package:dartz/dartz.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/search_repository.dart';
import '../data_source/search_data_source.dart';
import '../data_source/search_data_source_impl.dart';

final searchRepositoryProvider = Provider((ref) =>
    SearchRepositoryImpl(dataSource: ref.read(searchRepositoryImplProvider)));

class SearchRepositoryImpl implements SearchRepository{
  SearchRepositoryImpl({required this.dataSource});


  SearchDataSource dataSource;
  @override
  Future<Map<String, dynamic>> getAStudent(String rollNumber)async {
    return await dataSource.getAStudent(rollNumber);
  }

  @override
  Future<Either<Map<String, dynamic>, List>> getStudentBySemester(String semester) async{


    return await dataSource.getStudentBySemester(semester);
  }
}