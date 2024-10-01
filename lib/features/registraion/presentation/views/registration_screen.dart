

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../../../core/utils/convertImageToUin8List.dart';
import '../../../../core/utils/customButton.dart';
import '../../../../core/utils/customDropDown.dart';
import '../../../../core/utils/customTextFormField.dart';
import '../../../../core/utils/validators/validators.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';

import '../../../train_face/presentation/riverpod/train_face_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

import '../riverpod/registraion_provider.dart';





class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, required this.faceDetector, required this.interpreter, required this.cameras});

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
  Uint8List? image;
  List<dynamic> embeddings = [];
  img.Image? imageToSave;

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

  late ByteData imageData;
  late Uint8List bytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final detectController = ref.watch(faceDetectionProvider('family').notifier);
    final trainController = ref.watch(trainFaceProvider('family').notifier);
    final registerController = ref.watch(registrationProvider.notifier);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;





    return Scaffold(
      appBar: AppBar(
        title:const  Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.018),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: screenHeight * 0.05,),


              (image!=null)? Center(
                child: SizedBox(

                  width: 112,
                  height: 112,

                  child: GestureDetector(
                    onTap: (){
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Capture'),
                              onTap: () {
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
                              },

                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () {
                                // Navigator.pop(context);
                                trainFromGallery(
                                  formKey: _formKey,
                                  registerController: registerController,
                                  detectController: detectController,
                                  trainController: trainController,
                                  personName: name.trim(),
                                  semester: semester,
                                  session: session,
                                  rollNumber: rollNumber,
                                );
                                // Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },

                    child: CircleAvatar(
                      radius: 100.0, // Controls the size of the avatar

                      backgroundColor: Colors.black, // Black space around the image
                      child: ClipOval(
                        child: SizedBox(
                          width: 112, // The actual width of your image
                          height: 112, // The actual height of your image
                          child: Image.memory(
                            image!,
                            fit: BoxFit.contain, // Ensures the image is not stretched
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ):  Center(
                child: GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading:const  Icon(Icons.camera_alt),
                            title: const Text('Capture'),
                            onTap: () {
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
                            },

                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () {
                              // Navigator.pop(context);
                              trainFromGallery(
                                formKey: _formKey,
                                registerController: registerController,
                                detectController: detectController,
                                trainController: trainController,
                                personName: name.trim(),
                                semester: semester,
                                session: session,
                                rollNumber: rollNumber,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: screenWidth*0.14, // Adjust the radius as per your need
                    // radius: 56,
                    backgroundImage: const AssetImage('assets/face_attendance.png'),
                    backgroundColor: Colors.transparent, // Optional: Make the background transparent
                  )
                ),
              ),
         const Center(
            child: Text(
              'Tap To Register Face',
              style: TextStyle(
                color: Colors.grey,
              )
          ),),


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
                        onChanged: (value) => name = value.trim(),
                        validator: Validator.personNameValidator,
                        height: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      customTextFormField(
                        hintText: 'Roll Number',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => rollNumber = value.trim(),
                        validator: Validator.rollNumberValidator,
                        height: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      customDropDown(
                        itemList: sessionList,
                        hintText: 'Session',
                        value: session,
                        validator: Validator.sessionValidator,
                        onChanged: (value){
                          session = value;
                        }, height: screenHeight
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      customDropDown(
                          itemList: semesterList,
                          value: semester,
                         validator: Validator.semesterValidator,
                          onChanged: (input) {
                            semester = input;
                          },
                          height: screenHeight,
                          hintText: 'Semester',
                      ),


                      SizedBox(height: screenHeight * 0.06),
                      Padding(
                        padding: EdgeInsets.only(left:screenHeight * 0.06,right: screenHeight * 0.06 ),
                        child: CustomButton(
                          screenHeight: screenHeight,
                          buttonName: 'Add',
                          icon: Icon(
                            Icons.person_add_alt_1,
                            size: 30,
                            weight: screenWidth*2,
                          color: Colors.white,),

                          onpressed: () {


                          if (_formKey.currentState!.validate()&&embeddings.isNotEmpty && imageToSave!=null) {
                            registerController.createStudent( embeddings, imageToSave!, name,
                                rollNumber,  session!, semester!,context);
                          }


                          if(embeddings.isEmpty){
                            Fluttertoast.showToast(
                              msg: 'Image not selected', // Show the first error message
                              // toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        },
                        ),
                      ),
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



  Future<void> trainFromGallery(
      {formKey,
        registerController,
        detectController,
        trainController,
        personName,
        rollNumber,
        session,
        semester,
      }) async {

      //detect face and train the mobilefacenet model
      await detectController
          .detectFacesFromImages(widget.faceDetector, 'Train from gallery')
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

       List<dynamic> embedding =  await trainController.pickImagesAndTrain(
             widget.interpreter, imgList);

        if(embedding.isNotEmpty){
          setState(() {

            embeddings = embedding;
            imageToSave = imgList[0];

            image = convertImageToUint8List(imgList[0]);
          });
        }
        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
        Navigator.pop(context);
      });
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


        List<dynamic> embedding =  await trainController.pickImagesAndTrain(widget.interpreter, imgList,);
        if(embedding.isNotEmpty){
          setState(() {

            embeddings = embedding;
            imageToSave = imgList[0];

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


}






