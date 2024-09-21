
import 'package:dartz/dartz.dart';

abstract class SearchRepository{
  Future<Map<String, dynamic>> getAStudent(String rollNumber);
  Future<Either<Map<String, dynamic>, List>> getStudentBySemester(String semester);
}