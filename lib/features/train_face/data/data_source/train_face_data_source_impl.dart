


import 'dart:convert';


import 'package:face_roll_student/core/network/rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'train_face_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:typed_data';







final trainFaceDataSourceProvider = Provider((ref) => TrainFaceDataSourceImpl(restClient: ref.read(restClientProvider)));


class TrainFaceDataSourceImpl implements TrainFaceDataSource{

  TrainFaceDataSourceImpl({required this.restClient});

 RestClient restClient;

  @override
 Future<void> saveOrUpdateJsonInSharedPreferences(String key, listOfOutputs,String nameOfJsonFile ) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the JSON file exists in SharedPreferences
    // String? existingJsonString = prefs.getString('testMap');
    // String? existingJsonString = prefs.getString('liveTraining');
    String? existingJsonString = prefs.getString(nameOfJsonFile);


    for(int i  = 0; i<listOfOutputs.length; i++){
      print('The $i st list of $key is ${listOfOutputs[i]} ');
    }


    if (existingJsonString == null) {
      // If the JSON file doesn't exist, create a new one with the provided key and value
      Map<String, dynamic> newJsonData = {key: listOfOutputs};
      // Map<String, List<List<double>>> newJsonData = {key: listOfOutputs};
      await prefs.setString(nameOfJsonFile, jsonEncode(newJsonData));

    } else {
      // If the JSON file exists, update it
      Map<String, dynamic> existingJson =
      json.decode(existingJsonString) as Map<String, dynamic>;

      // Check if the key already exists in the JSON
      if (existingJson.containsKey(key)) {
        // If the key exists, update its value
        existingJson[key] = listOfOutputs;
      } else {
        // If the key doesn't exist, add a new key-value pair
        existingJson[key] = listOfOutputs;
      }

      // Save the updated JSON back to SharedPreferences
      // await prefs.setString('testMap', jsonEncode(existingJson));
      // await prefs.setString('liveTraining', jsonEncode(existingJson));
      await prefs.setString(nameOfJsonFile, jsonEncode(existingJson));
      dynamic printMap = await readMapFromSharedPreferencesFromTrainDataSource(nameOfJsonFile);
      print('The name of the file is $nameOfJsonFile');
      print(printMap);
    }
  }
  @override
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferencesFromTrainDataSource(String nameOfJsonFile) async {
    final prefs = await SharedPreferences.getInstance();
    // final jsonMap = prefs.getString('testMap');
    // final jsonMap = prefs.getString('liveTraining');
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // final resultMap = decodedMap.map((key, value) {
      //   return MapEntry(
      //     key,
      //     value.map((str) => str.split(',').map(int.parse).toList()).toList(),
      //   );
      // });
      // return resultMap;
      return decodedMap;
    } else {
      return {};
    }
  }

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



    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     // Add token if required
    //   },
    //   body: jsonEncode(studentData),
    // );
    //
    // if (response.statusCode == 201) {
    //   print('Student created successfully');
    //   // getStudentByRollNumber(19702020);
    // } else {
    //   print('Failed to create student: ${response.body}');
    // }
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

