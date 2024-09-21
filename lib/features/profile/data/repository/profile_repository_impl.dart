import 'package:face_roll_student/core/network/rest_client.dart';
import 'package:face_roll_student/features/profile/domain/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // final apiService = ApiService();
  final restClient = ref.read(restClientProvider);
  return ProfileRepositoryImpl(restClient);
});


class ProfileRepositoryImpl implements ProfileRepository {
  // final ApiService apiService;
  final RestClient restClient;

  ProfileRepositoryImpl(this.restClient);

  @override
  Future<Map<String, dynamic>> deleteStudent(String rollNumber) async{
   return await restClient.deleteStudent(rollNumber);
  }

  @override
  Future<Map<String, dynamic>> updateStudent(String rollNumber, Map<String, dynamic> studentData)async {
    return await restClient.updateStudent(rollNumber, studentData);
  }


}
