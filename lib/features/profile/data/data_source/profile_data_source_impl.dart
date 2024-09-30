import 'package:face_roll_student/features/profile/data/data_source/profile_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/rest_client.dart';

final profileDataSourceRepositoryProvider = Provider<ProfileDataSourceImpl>((ref) {

  final restClient = ref.read(restClientProvider);
  return ProfileDataSourceImpl(restClient);
});



class ProfileDataSourceImpl implements ProfileDataSource{
  final RestClient restClient;
  ProfileDataSourceImpl(this.restClient);
  @override
  Future<Map<String, dynamic>> deleteStudent(String rollNumber)async {

    return await restClient.deleteStudent(rollNumber);
  }

  @override
  Future<Map<String, dynamic>> updateStudent(String rollNumber, Map<String, dynamic> studentData) async{
    return await restClient.updateStudent(rollNumber, studentData);
  }

}