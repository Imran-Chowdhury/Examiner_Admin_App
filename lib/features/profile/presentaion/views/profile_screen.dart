import 'package:camera/camera.dart';
import 'package:face_roll_student/core/utils/background_widget.dart';
import 'package:face_roll_student/core/utils/customButton.dart';
import 'package:face_roll_student/features/profile/presentaion/riverpod/profile_screen_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../../core/constants/constants.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../../../train_face/presentation/riverpod/train_face_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;


class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({required this.faceDetector, required this.interpreter,
    required this.cameras, required this.originalName, required this.originalRollNumber,
    required this.originalSemester, required this.originalSession});

  final FaceDetector faceDetector;
  final tf_lite.Interpreter interpreter;
  final List<CameraDescription> cameras;
  late String originalName;
  late String originalRollNumber;
  late String? originalSession;
  late String? originalSemester;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController rollEditingController = TextEditingController();

  // Original data passed through the constructor


  // Current data being edited
  late String name;
  late String rollNumber;
  String? session;
  String? semester;
  final String fileName = 'Total Students';

  final List<String> sessionList = [
    '2017-18',
    '2018-19',
    '2019-20',
    '2020-21',
    '2021-22',
    '2022-23',
    '2023-24',
    '2024-25'
  ];

  final List<String> semesterList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize original data with values passed through the constructor
    // originalName = widget.name;
    // originalRollNumber = widget.rollNumber;
    // originalSession = widget.session;
    // originalSemester = widget.semester;

    // Set the initial current data to match the original data
    // name = nameEditingController.text;
    name = widget.originalName;
    rollNumber = widget.originalRollNumber;
    session = widget.originalSession;
    semester = widget.originalSemester;


    nameEditingController.text = widget.originalName;
    rollEditingController.text = widget.originalRollNumber;
  }

  @override
  Widget build(BuildContext context) {
    final profileController = ref.watch(profileProvider.notifier);
    final isEditing = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorConst.backgroundColor,
                Color.fromARGB(92, 95, 167, 231),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              profileController.toggleEditing();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),
          SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Capture'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.25,
                    backgroundImage: AssetImage('assets/Imran_picture.jpeg'),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Column(
                      children: [
                        buildTextFormField(
                          hintText: 'Name',
                          controller: nameEditingController,
                          onChanged: (value) => nameEditingController.text = value.trim(),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                          enabled: isEditing,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                        buildTextFormField(
                          hintText: 'Roll Number',
                          controller: rollEditingController,
                          keyboardType: TextInputType.number,
                          // onChanged: (value) => rollNumber = value.trim(),
                          onChanged: (value) => rollEditingController.text = value.trim(),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your roll number'
                              : null,
                          enabled: isEditing,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                        _buildCustomDropDown(
                          itemList: sessionList,
                          hintText: 'Session',
                          value: session,
                          onChanged: isEditing
                              ? (value) {
                            session = value;
                          }
                              : null,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                        buildSemesterDropDown(
                          itemList: semesterList,
                          value: semester,
                          onChanged: isEditing ? (input) {
                            semester = input;
                          } : null,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                        if (isEditing)
                          buildButtonRow(
                            context,
                                () {
                              // Cancel editing and revert to original data
                              setState(() {
                                // name = widget.originalName;
                                // rollNumber = widget.originalRollNumber;
                                nameEditingController.text = widget.originalName;
                                rollEditingController.text = widget.originalRollNumber;
                                session = widget.originalSession;
                                semester = widget.originalSemester;
                              });
                              profileController.resetEditing();
                            },
                                () {
                              // Save and exit edit mode
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                profileController.resetEditing();

                                // Update the original data to match the current data
                                widget.originalName = name;
                                widget.originalRollNumber = rollNumber;
                                widget.originalSession = session;
                                widget.originalSemester = semester;
                              }
                            },
                            // MediaQuery.of(context).size.height,
                            // isEditing,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField({
    required String hintText,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
    required TextEditingController controller,

  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: const BorderSide(
            color: Color(0xFF0cdec1),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(800.0),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildCustomDropDown({
    required List<String> itemList,
    required String hintText,
    required String? value,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(800.0),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
      ),
      items: itemList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select your $hintText' : null,
    );
  }

  Widget buildSemesterDropDown({
    required List<String> itemList,
    required String? value,
    required void Function(String?)? onChanged,
  }) {
    return _buildCustomDropDown(
      itemList: itemList,
      hintText: 'Semester',
      value: value,
      onChanged: onChanged,
    );
  }

  Widget buildButtonRow(
      BuildContext context,
      VoidCallback onCancelPressed,
      VoidCallback onSavePressed,
      // double screenHeight,
      // bool isEditing,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: onCancelPressed,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSavePressed,
          child: Text('Save'),
        ),
      ],
    );
  }
}




//
// class ProfileScreen extends ConsumerStatefulWidget {
//   ProfileScreen({required this.faceDetector, required this.interpreter, required this.cameras});
//
//   final FaceDetector faceDetector;
//   final tf_lite.Interpreter interpreter;
//   final List<CameraDescription> cameras;
//
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   String name = '';
//   String rollNumber = '';
//   String? session;
//   String? semester;
//   final String fileName = 'Total Students';
//
//   final List<String> sessionList =  [
//     '2017-18',
//     '2018-19',
//     '2019-20',
//     '2020-21',
//     '2021-22',
//     '2022-23',
//     '2023-24',
//     '2024-25'
//   ];
//
//
//   final List<String> semesterList = [
//     '1',
//     '2',
//     '3',
//     '4',
//     '5',
//     '6',
//     '7',
//     '8'
//   ];
//   @override
//   void initState() {
//     super.initState();
//     // If you need to do any initialization with faceDetector, interpreter, or cameras, do it here.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final detectController = ref.watch(faceDetectionProvider('family').notifier);
//     final detectState = ref.watch(faceDetectionProvider('family'));
//     final trainController = ref.watch(trainFaceProvider('family').notifier);
//     final recognizeState = ref.watch(recognizefaceProvider('family'));
//     ProfileNotifier profileController = ref.watch(profileProvider.notifier);
//     final isEditing = ref.watch(profileProvider);
//
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 ColorConst.backgroundColor,
//                 Color.fromARGB(92, 95, 167, 231),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
//             onPressed: () {
//               profileController.toggleEditing();
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           const BackgroundContainer(),
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onLongPress: () {
//                     // Show capture and gallery options
//                     showModalBottomSheet(
//                       context: context,
//                       builder: (context) => Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ListTile(
//                             leading: Icon(Icons.camera_alt),
//                             title: Text('Capture'),
//                             onTap: () {
//                               // Handle capture option
//                               Navigator.pop(context);
//                             },
//                           ),
//                           ListTile(
//                             leading: Icon(Icons.photo_library),
//                             title: Text('Gallery'),
//                             onTap: () {
//                               // Handle gallery option
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   child: CircleAvatar(
//                     radius: MediaQuery.of(context).size.width * 0.25,
//                     backgroundImage: AssetImage('assets/Imran_picture.jpeg'),
//                   ),
//                 ),
//                 Form(
//                   key: _formKey,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width * 0.05,
//                       vertical: MediaQuery.of(context).size.height * 0.02,
//                     ),
//                     child: Column(
//                       children: [
//                         buildTextFormField(
//                           hintText: 'Name',
//                           onChanged: (value) => name = value.trim(),
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Please enter your name'
//                               : null,
//                           enabled: isEditing, // Enable editing based on state
//                         ),
//                         SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//                         buildTextFormField(
//                           hintText: 'Roll Number',
//                           keyboardType: TextInputType.number,
//                           onChanged: (value) => rollNumber = value.trim(),
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Please enter your roll number'
//                               : null,
//                           enabled: isEditing, // Enable editing based on state
//                         ),
//                         SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//                         _buildCustomDropDown(
//                             itemList: sessionList,
//                             hintText: 'Session',
//                             value: session,
//                             onChanged: isEditing
//                                 ? (value) {
//                               session = value;
//                             }
//                                 : null),
//                         SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//                         buildSemesterDropDown(
//                             itemList: semesterList,
//                             value: semester,
//                             onChanged: isEditing? (input) {
//                               semester = input;
//                             } : null),
//                             // onChanged:  (input) {
//                             //   semester = input;
//                             // }),
//                         SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//                         if (isEditing)
//                           buildButtonRow(
//                             context,
//                                 () {
//                               // Cancel editing
//                               // ref.read(editModeProvider.notifier).state = false;
//                                   profileController.resetEditing();
//                             },
//                                 () {
//                               // Save and exit edit mode
//                               if (_formKey.currentState!.validate()) {
//                                 _formKey.currentState?.save();
//                                 // ref.read(editModeProvider.notifier).state = false;
//                                 profileController.resetEditing();
//                               }
//                             },
//                             MediaQuery.of(context).size.height,
//                             isEditing,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildTextFormField({
//     required String hintText,
//     required void Function(String) onChanged,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//     required bool enabled,
//   }) {
//     return TextFormField(
//       enabled: enabled,
//       decoration: InputDecoration(
//         hintText: hintText,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: const BorderSide(
//             color: Colors.black,
//             width: 2.0,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: const BorderSide(
//             color: Color(0xFF0cdec1),
//             width: 2.0,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(800.0),
//           borderSide: const BorderSide(
//             color: Colors.red,
//             width: 2.0,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: const BorderSide(
//             color: Colors.red,
//             width: 2.0,
//           ),
//         ),
//       ),
//       keyboardType: keyboardType,
//       onChanged: onChanged,
//       validator: validator,
//     );
//   }
//
//   Widget _buildCustomDropDown({
//     required List<String> itemList,
//     required String hintText,
//     required String? value,
//     required void Function(String?)? onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       icon: const Icon(Icons.arrow_drop_down),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         hintText: hintText,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(800.0),
//           borderSide: const BorderSide(
//             color: Colors.red,
//             width: 2.0,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(80.0),
//           borderSide: const BorderSide(
//             color: Colors.red,
//             width: 2.0,
//           ),
//         ),
//       ),
//       items: itemList.map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       validator: (value) => value == null ? 'Please select your $hintText' : null,
//     );
//   }
//
//   Widget buildSemesterDropDown({
//     required List<String> itemList,
//     required String? value,
//     required void Function(String?)? onChanged,
//   }) {
//     return _buildCustomDropDown(
//       itemList: itemList,
//       hintText: 'Semester',
//       value: value,
//       onChanged: onChanged,
//     );
//   }
//
//
//
//   // Widget buildButtonRow(
//   //     BuildContext context,
//   //     FaceDetectionNotifier detectController,
//   //     TrainFaceNotifier trainController,
//   //     double screenHeight
//   //     ) {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: [
//   //       CustomButton(
//   //         onPressed: (){
//   //
//   //
//   //
//   //           if (_formKey.currentState!.validate()) {
//   //             print(name);
//   //             print(session);
//   //             print(semester);
//   //             print(rollNumber);
//   //
//   //
//   //
//   //             captureAndTrainImage(
//   //                 formKey: _formKey,
//   //                 context: context,
//   //                 detectController: detectController,
//   //                 trainController: trainController,
//   //                 personName: name,
//   //                 rollNumber: rollNumber,
//   //                 session: session,
//   //                 semester: semester,
//   //                 fileName: fileName);
//   //           }
//   //
//   //
//   //         },
//   //         buttonName: 'Capture',
//   //         icon: const Icon(Icons.camera),
//   //       ),
//   //
//   //       SizedBox(width: screenHeight * 0.08), // 4% of screen height
//   //       CustomButton(
//   //         onPressed: (){
//   //
//   //
//   //
//   //           if (_formKey.currentState!.validate()) {
//   //             print(name);
//   //             print(session);
//   //             print(semester);
//   //             print(rollNumber);
//   //
//   //             trainFromGallery(
//   //                 formKey: _formKey,
//   //                 detectController: detectController,
//   //                 trainController: trainController,
//   //                 personName: name.trim(),
//   //                 semester: semester,
//   //                 session: session,
//   //                 rollNumber: rollNumber,
//   //                 fileName: fileName);
//   //           }
//   //
//   //
//   //
//   //         },
//   //         buttonName: 'Gallery',
//   //         icon: const Icon(Icons.camera),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Future<void> trainFromGallery(
//       {formKey,
//         detectController,
//         trainController,
//         personName,
//         rollNumber,
//         session,
//         semester,
//         fileName}) async {
//     if (formKey.currentState!.validate()) {
//       //detect face and train the mobilefacenet model
//       await detectController
//           .detectFacesFromImages(widget.faceDetector, 'Train from gallery')
//           .then((imgList) async {
//         final stopwatch = Stopwatch()..start();
//
//         await trainController.pickImagesAndTrain(
//             personName,rollNumber, session, semester, widget.interpreter, imgList, fileName);
//
//         // personName = '';
//         // setState(() {
//         //   personName = '';
//         //   rollNumber = '';
//         //   session = null;
//         //   semester = null;
//         // });
//
//         stopwatch.stop();
//         final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
//         print('Detection and Training Execution Time: $elapsedSeconds seconds');
//       });
//     } else {
//       // Validation failed
//       // Fluttertoast.showToast(msg: 'Failed to add $personName !');
//       print('Validation failed');
//     }
//   }
//
//
//   Future<void> captureAndTrainImage(
//       {formKey,
//         context,
//         detectController,
//         trainController,
//         personName,
//         rollNumber,
//         session,
//         semester,
//         fileName}) async {
//     // if (formKey.currentState!.validate()) {
//
//     final List<XFile>? capturedImages = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => CameraCaptureScreen(
//             cameras: widget.cameras,
//           )),
//     );
//
//     if (capturedImages != null) {
//       await detectController
//           .detectFacesFromImages(
//           widget.faceDetector, 'Train from captures', capturedImages)
//           .then((imgList) async {
//         final stopwatch = Stopwatch()..start();
//
//         await trainController.pickImagesAndTrain(
//             personName, rollNumber, session, semester, widget.interpreter, imgList, fileName);
//
//         // setState(() {
//         //   personName = '';
//         //   rollNumber = '';
//         //   session = null;
//         //   semester = null;
//         // });
//
//         // personName = '';
//
//         stopwatch.stop();
//         final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
//         print('Detection and Training Execution Time: $elapsedSeconds seconds');
//       });
//     }
//   }
//   // Method to build button row with save and cancel buttons
//   Widget buildButtonRow(BuildContext context, VoidCallback onCancel, VoidCallback onSave,
//       double screenHeight, bool isEditing) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton.icon(
//           icon: Icon(Icons.cancel),
//           label: Text('Cancel'),
//           onPressed: onCancel,
//         ),
//         ElevatedButton.icon(
//           icon: Icon(Icons.save),
//           label: Text('Save'),
//           onPressed: onSave,
//         ),
//       ],
//     );
//   }
// }






