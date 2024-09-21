import 'package:dartz/dartz.dart';

abstract class SearchDataSource{
  Future<Map<String,dynamic>> getAStudent(String rollNumber);
  Future<Either<Map<String,dynamic>,List<dynamic>>> getStudentBySemester(String semester);
}