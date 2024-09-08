
import 'package:image/image.dart' as img;


abstract class RegistrationDataSource{

  Future<Map<String,dynamic>> createStudent(List embedding, img.Image image, String studentName, String rollNumber, String session, String semesterId,);
  // Future<void> saveOrUpdateJsonInSharedPreferences(String key, dynamic listOfOutputs, String nameOfJsonFile);
  // Future<Map<String, List<dynamic>>> readMapFromSharedPreferencesFromTrainDataSource(String nameOfJsonFile);
}


