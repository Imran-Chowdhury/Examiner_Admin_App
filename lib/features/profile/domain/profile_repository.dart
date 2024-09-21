abstract class ProfileRepository{
  Future<Map<String,dynamic>> deleteStudent(String rollNumber);
  Future<Map<String,dynamic>> updateStudent(String rollNumber, Map<String, dynamic> studentData);
}