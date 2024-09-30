

import 'package:tflite_flutter/tflite_flutter.dart';


abstract class TrainFaceRepository{

 Future<List<dynamic>> getOutputList(List trainings, Interpreter interpreter);

}