
import 'package:image/image.dart' as img;


abstract class RegistrationDataSource{

  Future<Map<String,dynamic>> createStudent(List embedding, img.Image image, String studentName, String rollNumber, String session, String semesterId,);

}


