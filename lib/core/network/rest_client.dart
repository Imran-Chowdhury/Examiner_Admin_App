
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:face_roll_student/core/network/urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final restClientProvider = Provider((ref) => RestClient());

class RestClient{
  Future<Map<String,dynamic>> createStudent(Map<String, dynamic> studentData) async {
    print('The student to be saved is $studentData');
    const url = Urls.baseUrl;
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      body: jsonEncode(studentData),
    );

    if (response.statusCode == 201) {
      print('Student created successfully');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Failed to create student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return errorBody;
    }
  }


  Future<Map<String,dynamic>> updateStudent(String rollNumber, Map<String, dynamic> studentData) async {
    print('The student to be saved is $studentData');
   String url = Urls.baseUrl+'$rollNumber/partial-update/';
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',

        // Add token if required
      },
      body: jsonEncode(studentData),
    );

    if (response.statusCode == 200) {
      print('Student updated successfully');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Failed to update student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return errorBody;
    }
  }


  Future<Map<String,dynamic>> getAStudent(String rollNumber) async {
    String url = '${Urls.baseUrl}$rollNumber/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },

    );

    if (response.statusCode == 200) {
      print('Student Found!');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Failed to get student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return errorBody;
    }
  }

  Future<Either<Map<String,dynamic>,List<dynamic>>> getStudentBySemester(String semester) async {
    // Students/semester/1/
    String url = '${Urls.baseUrl}semester/$semester/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },

    );

    if (response.statusCode == 200) {
      print('Student list Found!');
      final List<dynamic> responseBody = jsonDecode(response.body);
      return Right(responseBody);
    } else {
      print('Failed to get student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return Left(errorBody);
    }
  }


  Future<Map<String,dynamic>> deleteStudent(String rollNumber) async {
    String url = '${Urls.baseUrl}$rollNumber/';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },

    );

    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;


    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      print(errorBody);
      return errorBody;

    }
  }
}