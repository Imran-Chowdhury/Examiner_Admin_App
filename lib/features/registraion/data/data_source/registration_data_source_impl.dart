


import 'dart:convert';


import 'package:face_roll_student/core/network/rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'registration_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:typed_data';







final registraionDataSourceProvider = Provider((ref) => RegistrationDataSourceImpl(restClient: ref.read(restClientProvider)));


class RegistrationDataSourceImpl implements RegistrationDataSource{

  RegistrationDataSourceImpl({required this.restClient});

 RestClient restClient;


  @override
  Future<Map<String, dynamic>> createStudent(List embedding, img.Image image, String studentName,
      String rollNumber, String session, String semesterId,) async {
    // const url = 'http://192.168.0.106:8000/api/Students/'; // Replace with your API URL

    Uint8List uint8list = convertImageToUint8List(image);

    final studentData = {
      'name': studentName,
      'roll_number': rollNumber,
      'session': session,
      'semester': int.parse(semesterId),
      'image': uint8list, // Example list of integers for image
      'face_embeddings': embedding // Example list of floats for embeddings
    };

   return restClient.createStudent(studentData);




  }
  Uint8List convertImageToUint8List(img.Image image) {
    // Encode the image to PNG format
    final List<int> pngBytes = img.encodePng(image);

    // Convert the List<int> to Uint8List
    final Uint8List uint8List = Uint8List.fromList(pngBytes);
    print('The uint8List is $uint8List');

    return uint8List;
  }



}

