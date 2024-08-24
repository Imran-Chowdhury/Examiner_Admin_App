

import 'package:tflite_flutter/tflite_flutter.dart';


abstract class TrainFaceRepository{
 Future<Map<String, dynamic>> getOutputList(String name, String rollNumber, String session, String semester, List trainings, Interpreter interpreter, String nameOfJsonFile);

}