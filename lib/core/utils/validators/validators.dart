


class Validator{


  static  String? personNameValidator(String? value){

    if (value == null || value.isEmpty) {
      return 'Please enter your name!';
    }
    return null;
  }

  static String? rollNumberValidator(String? value){

    if (value == null || value.isEmpty) {
      return 'Please enter your roll number!';
    }
    return null;
  }

  static String? semesterValidator(String? value){

    if (value == null || value.isEmpty) {
      return 'Please select your semester!';
    }
    return null;
  }

  static String? sessionValidator(String? value){

    if (value == null || value.isEmpty) {
      return 'Please select your session!';
    }
    return null;
  }

  // static String? profileSemesterValidator(String? value){
  //
  //   if (value == null || value.isEmpty) {
  //     return 'Please select your semester!';
  //   }
  //   return null;
  // }
  //
  //
  // static String? profileSessionValidator(String? value){
  //
  //   if (value == null || value.isEmpty) {
  //     return 'Please select your session!';
  //   }
  //   return null;
  // }


}