
import 'package:face_roll_student/features/profile/domain/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_source/profile_data_source.dart';
import '../data_source/profile_data_source_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {

  final dataSource = ref.read(profileDataSourceRepositoryProvider);
  return ProfileRepositoryImpl(dataSource);
});


class ProfileRepositoryImpl implements ProfileRepository {

   ProfileDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> deleteStudent(String rollNumber) async{
   return await dataSource.deleteStudent(rollNumber);
  }

  @override
  Future<Map<String, dynamic>> updateStudent(String rollNumber, Map<String, dynamic> studentData)async {
    return await dataSource.updateStudent(rollNumber, studentData);
  }


}
