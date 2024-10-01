import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../../core/utils/convertImageToUin8List.dart';
import '../../../../core/utils/customButton.dart';
import '../../../../core/utils/customDropDown.dart';
import '../../../../core/utils/customTextFormField.dart';
import '../../../../core/utils/validators/validators.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';
import '../../../train_face/presentation/riverpod/train_face_provider.dart';
import '../riverpod/profile_screen_provider.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key, required this.faceDetector, required this.interpreter,
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
              await profileController.deleteStudent(rollNumber, context);

              Navigator.of(context).pop(); // Close the dialog


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
        updatedData['name'] = nameEditingController.text.trim();
      }

      // Check if the roll number is modified
      if (rollEditingController.text.trim() != widget.originalRollNumber.trim()) {
        updatedData['roll_number'] = rollEditingController.text.trim();
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
        profileController.updateStudent(rollNumber,  updatedData, context);
      }else{
        editController.resetEditing();
        Fluttertoast.showToast(msg: 'No changes are made.');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }

    void resetValues(){
      setState(() {
        image = Uint8List.fromList(widget.uint8list);  // Revert back to the original image
        embeddings = [];  // Clear embeddings
        nameEditingController.text = widget.originalName;  // Reset name field
        rollEditingController.text = widget.originalRollNumber;  // Reset roll number field
        session = widget.originalSession;  // Reset session
        semester = widget.originalSemester;  // Reset semester
      });
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;


    return Scaffold(
      appBar: AppBar(
        title:const  Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        actions: [

          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.black),
            onPressed: () {
              if (isEditing) {
                // If in editing mode, execute the cancel functionality to revert changes
                resetValues();

                // Reset the editing state
                editController.resetEditing();
              } else {
                // If not in editing mode, toggle to edit mode
                editController.toggleEditing();
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete , color: Colors.black),
            onPressed: () {
              showDeleteDialog(context, profileController);

              // profileController.toggleEditing();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.018),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05,),
              GestureDetector(
                onTap: () {
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

                  child:  GestureDetector(
                    onTap: () {
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
                      height: 112,
                      width: 112,
                      child: CircleAvatar(
                        radius: 100, // Controls the size of the avatar
                        // backgroundColor: Colors.white, // White space around the image
                        backgroundColor: Colors.black, // Black space around the image
                        child: ClipOval(
                          child: SizedBox(
                            width: 120, // The actual width of your image
                            height: 120, // The actual height of your image
                            child: Image.memory(
                              image,
                              fit: BoxFit.contain, // Ensures the image is not stretched
                            ),
                          ),
                        ),
                      ),
                    ),
                  )

              ),
              SizedBox(height: screenHeight * 0.057,),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [

                      customTextFormField(
                        hintText: 'Name',
                        controller: nameEditingController,
                        onChanged: (value) => nameEditingController.text = value,
                          validator: Validator.personNameValidator,
                          height:  screenHeight,
                          enabled: isEditing,
                      ),

                      SizedBox(height: screenHeight * 0.06),

                      customTextFormField(
                          hintText: 'Roll Number',
                          keyboardType: TextInputType.number,
                          controller: rollEditingController,
                          onChanged: (value) => rollEditingController.text = value,
                          validator: Validator.rollNumberValidator,
                          height: screenHeight,
                      enabled: isEditing
                      ),
                      SizedBox(height: screenHeight * 0.06),

                      customDropDown(
                          itemList: sessionList,
                          hintText: 'Session',
                          value: session,
                          validator: Validator.sessionValidator,
                          height: screenHeight,
                          onChanged: isEditing
                              ? (value) {
                            setState(() {
                              session = value;
                            });
                            // session = value;
                          } : null,
                      ),
                      SizedBox(height: screenHeight * 0.06),


                      customDropDown(
                        itemList: semesterList,
                        value: semester,
                        validator: Validator.semesterValidator,
                        height: screenHeight,
                        hintText: 'Semester',
                        onChanged: isEditing ? (input) {
                          setState(() {
                            semester = input;
                          });
                          // semester = input;
                        } : null,
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      if (isEditing)
                        CustomButton(
                            screenHeight: screenHeight,
                            buttonName: 'Update',
                            onpressed:     (){
                              if (_formKey.currentState!.validate()) {
                                saveProfile(profileController);
                              }
                            },
                            icon: const Icon(Icons.update),),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    required double height,

  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        // labelText: labelText,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF0cdec1),
            // Colors.blue,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(height * 0.023),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(height * 0.023),
        ),
      ),

      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }


  Widget buildButtonRow(
      BuildContext context,
      // VoidCallback onCancelPressed,
      ProfileNotifier profileController,
      VoidCallback onSavePressed,

      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onSavePressed,
          child: Text('Save'),
        ),
      ],
    );
  }
}





