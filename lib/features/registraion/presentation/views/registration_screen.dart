import 'package:camera/camera.dart';
import 'package:face_roll_student/core/utils/background_widget.dart';
import 'package:face_roll_student/core/utils/customButton.dart';
import 'package:face_roll_student/features/registraion/presentation/riverpod/registraion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../../core/constants/constants.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../../../train_face/presentation/riverpod/train_face_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;





class RegistrationScreen extends ConsumerStatefulWidget {
  RegistrationScreen({required this.faceDetector, required this.interpreter, required this.cameras});

  final FaceDetector faceDetector;
  final tf_lite.Interpreter interpreter;
  final List<CameraDescription> cameras;

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String rollNumber = '';
  String? session;
  String? semester;
  final String fileName = 'Total Students';

  final List<String> sessionList =  [
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
    // If you need to do any initialization with faceDetector, interpreter, or cameras, do it here.
  }

  @override
  Widget build(BuildContext context) {
    final detectController = ref.watch(faceDetectionProvider('family').notifier);
    final trainController = ref.watch(trainFaceProvider('family').notifier);
    final detectState = ref.watch(faceDetectionProvider('family'));

    final recognizeState = ref.watch(recognizefaceProvider('family'));
    final registerController = ref.watch(registrationProvider.notifier);


    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Remove shadow
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
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),
          SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.05 * screenHeight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      children: [
                        buildTextFormField(
                          hintText: 'Name',
                          onChanged: (value) => name = value.trim(),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                        ),
                        SizedBox(height: screenHeight * 0.06),
                        buildTextFormField(
                          hintText: 'Roll Number',
                          keyboardType: TextInputType.number,
                          onChanged: (value) => rollNumber = value.trim(),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your roll number'
                              : null,
                        ),
                        SizedBox(height: screenHeight * 0.06),
                        _buildCustomDropDown(
                          itemList: sessionList,
                          hintText: 'Session',
                          value: session,
                          onChanged: (value){
                            session = value;
                          }),
                        SizedBox(height: screenHeight * 0.06),
                        buildSemesterDropDown(
                          itemList: semesterList,
                          value: semester,
                          onChanged: (input) {
                            // semester = _mapSemesterToNumber(input);
                            semester = input;

                          }),

                        SizedBox(height: screenHeight * 0.06),
                        buildButtonRow(
                          context,
                          registerController,
                          detectController,
                          trainController,
                          screenHeight,
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
  }) {
    return TextFormField(
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
    required void Function(String?) onChanged,
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
      RegistrationNotifier registerController,
      FaceDetectionNotifier detectController,
      TrainFaceNotifier trainController,
      double screenHeight
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          onPressed: (){



            if (_formKey.currentState!.validate()) {
              print(name);
              print(session);
              print(semester);
              print(rollNumber);



              captureAndTrainImage(
                  formKey: _formKey,
                  context: context,
                  registerController: registerController,
                  detectController: detectController,
                  trainController: trainController,
                  personName: name,
                  rollNumber: rollNumber,
                  session: session,
                  semester: semester,
                  fileName: fileName);
            }


          },
          buttonName: 'Capture',
          icon: const Icon(Icons.camera),
        ),

        SizedBox(width: screenHeight * 0.08), // 4% of screen height
        CustomButton(
          onPressed: (){



            if (_formKey.currentState!.validate()) {
              print(name);
              print(session);
              print(semester);
              print(rollNumber);

              trainFromGallery(
                  formKey: _formKey,
                  registerController: registerController,
                  detectController: detectController,
                  trainController: trainController,
                  personName: name.trim(),
                  semester: semester,
                  session: session,
                  rollNumber: rollNumber,
                  fileName: fileName);
            }



          },
          buttonName: 'Gallery',
          icon: const Icon(Icons.camera),
        ),
      ],
    );
  }

  Future<void> trainFromGallery(
      {formKey,
        registerController,
        detectController,
        trainController,
        personName,
        rollNumber,
        session,
        semester,
        fileName}) async {
    if (formKey.currentState!.validate()) {
      //detect face and train the mobilefacenet model
      await detectController
          .detectFacesFromImages(widget.faceDetector, 'Train from gallery')
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

       List<dynamic> embedding =  await trainController.pickImagesAndTrain(
             widget.interpreter, imgList);

       registerController.createStudent( embedding, imgList[0], personName,
            rollNumber,  session, semester,context);




        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
      });
    } else {
      // Validation failed
      // Fluttertoast.showToast(msg: 'Failed to add $personName !');
      print('Validation failed');
    }
  }


  Future<void> captureAndTrainImage(
      {formKey,
        context,
        registerController,
        detectController,
        trainController,
        personName,
        rollNumber,
        session,
        semester,
        fileName}) async {
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


        //
        // List<dynamic> embedding =  await trainController.pickImagesAndTrain(
        //     personName,rollNumber, session, semester, widget.interpreter, imgList, fileName);


        List<dynamic> embedding =  await trainController.pickImagesAndTrain(widget.interpreter, imgList,);


        registerController.createStudent( embedding, imgList[0], personName,
            rollNumber,  session, semester,context);


        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
      });
    }
  }


}






