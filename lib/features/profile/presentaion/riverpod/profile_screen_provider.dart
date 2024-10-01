
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/base_state/attendance_state.dart';
import '../../../search/presentaion/riverpod/search_screen_provider.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/profile_repository.dart';




// Provider for ProfileNotifier
final editProvider = StateNotifierProvider<EditNotifier, bool>(
      (ref) => EditNotifier(),
);



// StateNotifier to manage the isEditing state
class EditNotifier extends StateNotifier<bool> {
  EditNotifier() : super(false);

  // Toggle editing state
  void toggleEditing() {
    state = !state;
  }

  // Reset editing state to false
  void resetEditing() {
    state = false;
  }

}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(
          repository: ref.read(profileRepositoryProvider),
        ref: ref
      ),
);



// StateNotifier to manage the isEditing state
class ProfileNotifier extends StateNotifier<ProfileState> {

  ProfileRepository repository;
  Ref ref;

  ProfileNotifier({required this.repository,required this.ref}) : super(const ProfileInitialState());

  Future<void> deleteStudent(String rollNumber, BuildContext context)async{

    // state = const ProfileLoadingState();
    final result = await repository.deleteStudent(rollNumber);
    if(result.containsKey('msg')){
      Fluttertoast.showToast(msg: result['msg']);
      ref.read(searchProvider.notifier).resetState();
      Navigator.pop(context);
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(msg: result['error']);

    }
  }

  Future<void> updateStudent(String rollNumber, Map<String,dynamic> studentData, BuildContext context) async{


    Map<String, dynamic> responseMap = await repository.updateStudent(rollNumber,studentData);
    // print(('The response map is $responseMap'));

    if (responseMap.containsKey('error') ) {
      // This is likely an error response
      Fluttertoast.showToast(
        msg: responseMap['error'], // Show the first error message
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      // This is likely a success response
      Fluttertoast.showToast(
        msg: '${responseMap['name']} has been updated successfully!',
        toastLength: Toast.LENGTH_LONG,
      );
      ref.read(searchProvider.notifier).resetState();
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }


  }

