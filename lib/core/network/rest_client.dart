
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:face_roll_student/core/network/urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final restClientProvider = Provider((ref) => RestClient());

class RestClient{
  Future<Map<String,dynamic>> createStudent(Map<String, dynamic> studentData) async {
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


  Future<Map<String,dynamic>> getAStudent(String rollNumber) async {
    String url = '${Urls.baseUrl}$rollNumber/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      // body: jsonEncode(studentData),
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
  // Future<Either<Map<String, dynamic>, Map<String, dynamic>>> createStudent(Map<String, dynamic> studentData) async {
  //   const url = Urls.createStudents;
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       // Add token if required
  //     },
  //     body: jsonEncode(studentData),
  //   );
  //
  //   if (response.statusCode == 201) {
  //     print('Student created successfully');
  //     final Map<String, dynamic> responseBody = jsonDecode(response.body);
  //     return Right(responseBody);
  //   } else {
  //     print('Failed to create student: ${response.body}');
  //     final Map<String, dynamic> errorBody = jsonDecode(response.body);
  //     return Left(errorBody);
  //   }
  // }
}