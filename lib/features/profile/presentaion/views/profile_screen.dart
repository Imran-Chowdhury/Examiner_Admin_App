import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_roll_student/core/utils/background_widget.dart';
import 'package:face_roll_student/features/profile/presentaion/riverpod/profile_screen_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../../core/constants/constants.dart';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';
import '../../../train_face/presentation/riverpod/train_face_provider.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({required this.faceDetector, required this.interpreter,
    required this.cameras, required this.originalName, required this.originalRollNumber,
    required this.originalSemester, required this.originalSession, required this.uint8list});

  final FaceDetector faceDetector;
  final tf_lite.Interpreter interpreter;
  final List<CameraDescription> cameras;
  late String originalName;
  late String originalRollNumber;
  late String? originalSession;
  late String? originalSemester;
  late List<int> uint8list;

  // Uint8List? image;

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
   List<dynamic> embeddings = [];
  late Uint8List image;
  // Uint8List? image;


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

    name = widget.originalName;
    rollNumber = widget.originalRollNumber;
    session = widget.originalSession;
    semester = widget.originalSemester;
    nameEditingController.text = widget.originalName;
    rollEditingController.text = widget.originalRollNumber;
    image = Uint8List.fromList(widget.uint8list);
  }
  Uint8List convertImageToUint8List(img.Image image) {
    // Encode the image to PNG format
    final List<int> pngBytes = img.encodePng(image);

    // Convert the List<int> to Uint8List
    final Uint8List uint8List = Uint8List.fromList(pngBytes);
    // print('The uint8List is $uint8List');

    return uint8List;
  }

  void showDeleteDialog(BuildContext context,ProfileNotifier profileController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Call the delete function
              // await ref.read(deleteExamProvider.notifier).deleteExam(courseId, examId);
              await profileController.deleteStudent(rollNumber, context);

              Navigator.of(context).pop(); // Close the dialog

              // await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId);

            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> trainFromGallery(
      {
        formKey,
        // registerController,
        detectController,
        trainController,
        profileController,
        // personName,
        // rollNumber,
        // session,
        // semester,
      }) async {
    if (formKey.currentState!.validate()) {
      //detect face and train the mobilefacenet model
      await detectController
          .detectFacesFromImages(widget.faceDetector, 'Train from gallery')
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

        List<dynamic> embedding =
        await trainController.pickImagesAndTrain(widget.interpreter, imgList);


        if(embedding.isNotEmpty){
          setState(() {
            embeddings = embedding;
            // widget.uint8list = imgList[0];
            image = convertImageToUint8List(imgList[0]);
          });
        }



        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
        Navigator.pop(context);
      });
    } else {

      print('Validation failed');
    }
  }


  Future<void> captureAndTrainImage(
      {
        formKey,
        context,

        detectController,
        trainController,
        profileController,

      }) async {
    // if (formKey.currentState!.validate()) {

    final List<XFile>? capturedImages = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraCaptureScreen(
            cameras: widget.cameras,
          )),
    );

    if (capturedImages != null) {
      await detectController
          .detectFacesFromImages(
          widget.faceDetector, 'Train from captures', capturedImages)
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

        // await trainController.pickImagesAndTrain(
        //     personName, rollNumber, session, semester, widget.interpreter, imgList, fileName);

        List<dynamic> embedding = await trainController.pickImagesAndTrain(widget.interpreter, imgList);

        if(embedding.isNotEmpty){
          setState(() {
            embeddings = embedding;
            // widget.uint8list = imgList[0];
            image = convertImageToUint8List(imgList[0]);
          });
        }


        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
        Navigator.pop(context);
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    // Uint8List? image;
    // Uint8List imageData = Uint8List.fromList(widget.uint8list);
    // Uint8List imageData = image ?? Uint8List.fromList(widget.uint8list);
    Uint8List imageData = image;
    final editController = ref.watch(editProvider.notifier);
    ProfileNotifier profileController = ref.watch(profileProvider.notifier);
    final isEditing = ref.watch(editProvider);
    final detectController = ref.watch(faceDetectionProvider('family').notifier);
    final trainController = ref.watch(trainFaceProvider('family').notifier);

    void saveProfile(ProfileNotifier profileController) {
      // print('The original image is ${widget.}');
      print('The image to is $image');
      print('The embedding is $embeddings');
      Map<String, dynamic> updatedData = {};

      // Check if the name is modified
      if (nameEditingController.text.trim() != widget.originalName.trim()) {
        updatedData['name'] = nameEditingController.text;
      }

      // Check if the roll number is modified
      if (rollEditingController.text.trim() != widget.originalRollNumber.trim()) {
        updatedData['roll_number'] = rollEditingController.text;
      }

      // Check if session or semester is modified
      if (session != widget.originalSession) {
        updatedData['session'] = session;
      }
      if (semester != widget.originalSemester) {
        updatedData['semester'] = int.parse(semester!);
      }

      // If a new image was selected
      if (embeddings.isNotEmpty) {
        updatedData['image'] = image;
        updatedData['face_embeddings'] = embeddings;
      }


      // Call the update function only if there are changes
      if (updatedData.isNotEmpty) {
        // print(updatedData);
        // print(updatedData['face_embeddings']);
        profileController.updateStudent(rollNumber,  updatedData, context);
      }
    }



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
          // IconButton(
          //   icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
          //   onPressed: () {
          //     editController.toggleEditing();
          //   },
          // ),
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              if (isEditing) {
                // If in editing mode, execute the cancel functionality to revert changes
                setState(() {
                  image = Uint8List.fromList(widget.uint8list);  // Revert back to the original image
                  embeddings = [];  // Clear embeddings
                  nameEditingController.text = widget.originalName;  // Reset name field
                  rollEditingController.text = widget.originalRollNumber;  // Reset roll number field
                  session = widget.originalSession;  // Reset session
                  semester = widget.originalSemester;  // Reset semester
                });

                // Reset the editing state
                editController.resetEditing();
              } else {
                // If not in editing mode, toggle to edit mode
                editController.toggleEditing();
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete , color: Colors.white),
            onPressed: () {
              showDeleteDialog(context, profileController);

              // profileController.toggleEditing();
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
                    (isEditing)? showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Capture'),
                            onTap: () {
                              captureAndTrainImage(
                                  context: context,
                                  detectController: detectController,
                                  trainController: trainController,
                                  profileController: profileController
                              );

                              //
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Gallery'),
                            onTap: () {
                              // Navigator.pop(context);
                              trainFromGallery(
                                formKey: _formKey,
                                detectController: detectController,
                                trainController: trainController,
                                profileController: profileController,
                              );
                              // Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ): null;
                  },

                  child: SizedBox(
                    ///container
                    width: 112,
                    height: 112,
                    // margin: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      imageData,
                      width: 112.0,
                      height: 112.0,
                      // fit: BoxFit.cover,
                    ),
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
                            //     () {
                            //       // Cancel editing and revert to original data
                            //       setState(() {
                            //         image = Uint8List.fromList(widget.uint8list); // Revert back to the original image
                            //         embeddings = [];  // Clear embeddings
                            //         nameEditingController.text = widget.originalName;  // Reset name field
                            //         rollEditingController.text = widget.originalRollNumber;  // Reset roll number field
                            //         session = widget.originalSession;  // Reset session
                            //         semester = widget.originalSemester;  // Reset semester
                            //       });
                            //
                            //   editController.resetEditing();
                            // },
                            profileController,
                              (){
                                if (_formKey.currentState!.validate()) {
                                  saveProfile(profileController);
                                }
                              }
                          )
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
      // VoidCallback onCancelPressed,
      ProfileNotifier profileController,
      VoidCallback onSavePressed,
      // double screenHeight,
      // bool isEditing,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //   onPressed: onCancelPressed,
        //   child: Text('Cancel'),
        // ),
        ElevatedButton(
          onPressed: onSavePressed,
          child: Text('Save'),
        ),
      ],
    );
  }
}





