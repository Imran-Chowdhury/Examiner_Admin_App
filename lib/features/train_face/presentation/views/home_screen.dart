import 'dart:convert';
import 'package:face_roll_student/features/registraion/presentation/views/registration_screen.dart';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/base_state.dart';
import '../../../../core/utils/background_widget.dart';
import '../../../../core/utils/convert_camera_image_to_img_image.dart';
import '../../../../core/utils/convert_camera_image_to_input_image.dart';
import '../../../../core/utils/customButton.dart';
import '../../../../core/utils/validators/validators.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_burst_shots.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';
import '../../../profile/presentaion/views/profile_screen.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../../../search/presentaion/views/search_screen.dart';
import '../riverpod/train_face_provider.dart';

// 1. extend [ConsumerStatefulWidget]
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
  // HomeScreen({super.key,
  //   required this.isolateInterpreter,
  //   required this.faceDetector,
  //   required this.cameras,
  //   required this.interpreter,
  // });

}

// 2. extend [ConsumerState]
class _HomeScreenState extends ConsumerState<HomeScreen> {

  late FaceDetector faceDetector;
  late tf_lite.Interpreter interpreter;
  List<CameraDescription> cameras = [];
  late tf_lite.IsolateInterpreter isolateInterpreter;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await loadModelsAndDetectors();
  }

  Future<void> loadModelsAndDetectors() async {
    // Load models and initialize detectors
    interpreter = await loadModel();
    isolateInterpreter =
    await IsolateInterpreter.create(address: interpreter.address);
    // livenessInterpreter = await loadLivenessModel();
    cameras = await availableCameras();

    // Initialize face detector
    final faceDetectorOptions = FaceDetectorOptions(
      minFaceSize: 0.2,
      performanceMode: FaceDetectorMode.accurate, // or .fast
    );
    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  void dispose() {
    // Dispose resources

    faceDetector.close();
    interpreter.close();
    isolateInterpreter.close();
    super.dispose();
  }

//////////////////////////keep this///////////////

  // Future<tf_lite.Interpreter> loadModel() async {
  //   InterpreterOptions interpreterOptions = InterpreterOptions();
  //   // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;

  //   if (Platform.isAndroid) {
  //     interpreterOptions.addDelegate(XNNPackDelegate(
  //         options:
  //             XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
  //   }

  //   if (Platform.isIOS) {
  //     interpreterOptions.addDelegate(GpuDelegate());
  //   }

  //   return await tf_lite.Interpreter.fromAsset(
  //     'assets/facenet_512.tflite',
  //     options: interpreterOptions..threads = Platform.numberOfProcessors,
  //   );
  // }

  Future<tf_lite.Interpreter> loadModel() async {
    // InterpreterOptions interpreterOptions = InterpreterOptions();
    // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;// didnt work for me

    // var interpreterOptions = InterpreterOptions()..threads = 2;
    var interpreterOptions = InterpreterOptions()
      ..addDelegate(GpuDelegateV2()); //good

    // if (Platform.isAndroid) {
    //   interpreterOptions.addDelegate(XNNPackDelegate(
    //       options:
    //           XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
    // }

    // if (Platform.isIOS) {
    //   interpreterOptions.addDelegate(GpuDelegate());
    // }

    return await tf_lite.Interpreter.fromAsset('assets/facenet_512.tflite',
        options: interpreterOptions);
  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    late String personName;

////////////////////////////////////////////////////////////changes///////////////////////////////////////////////
    // final detectController = ref.watch(faceDetectionProvider.notifier);
    // final detectState = ref.watch(faceDetectionProvider);
    // final trainController = ref.watch(trainFaceProvider.notifier);
    // final trainState = ref.watch(trainFaceProvider);
    // final recognizeController = ref.watch(recognizefaceProvider.notifier);
    // final recognizeState = ref.watch(recognizefaceProvider);
    // final TextEditingController textFieldController = TextEditingController();

    final detectController = ref.watch(faceDetectionProvider('family').notifier);
    final detectState = ref.watch(faceDetectionProvider('family'));
    final trainController = ref.watch(trainFaceProvider('family').notifier);
    final recognizeState = ref.watch(recognizefaceProvider('family'));
    final TextEditingController textFieldController = TextEditingController();

    String fileName = 'Total Students';
    // constant.allStudent;

    Uint8List convertImageToUint8List(img.Image image) {
      // Encode the image to PNG format
      final List<int> pngBytes = img.encodePng(image);

      // Convert the List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(pngBytes);
      print('The uint8List is $uint8List');

      return uint8List;
    }

    // debugPrint('the length of the camera is ${widget.cameras.length}');

    return GestureDetector(
      onTap: () {
        // Hide the keyboard when tapped outside of the text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3a3b45),
        body: Stack(
          children: [
            const BackgroundContainer(),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Padding(
                    // padding: EdgeInsets.only(top: height*0.03,bottom: height*0.04),
                    padding: EdgeInsets.only(top: 50, bottom: 40),
                    // padding: EdgeInsets.only(top: (height*0.07)),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 10.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          // padding: EdgeInsets.only( left: width*0.04, right: width*0.04, bottom: 50),
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 50),
                          child: TextFormField(
                            controller: textFieldController,
                            decoration: InputDecoration(
                              hintText: 'Enter Name',

                              filled:
                                  true, // Fill the background of the text field
                              fillColor:
                                  Colors.white, // Color inside the text field
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(80.0),
                                borderSide:
                                    BorderSide.none, // Remove the border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(80.0),
                                borderSide: const BorderSide(
                                  color: Colors.black, // Default border color
                                  width: 2.0, // Default border thickness
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(80.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0cdec1),
                                  // Gradient border when focused
                                  // gradient: LinearGradient(
                                  //   colors: [Color(0xFF0cdec1), Color(0xFF0ad8e6)],
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomRight,
                                  // ),
                                  width: 2.0, // Border thickness
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(800.0),
                                borderSide: const BorderSide(
                                  color: Colors
                                      .red, // Border color for error state
                                  width: 2.0, // Border thickness
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(80.0),
                                borderSide: const BorderSide(
                                  color: Colors
                                      .red, // Border color for error state when focused
                                  width: 2.0, // Border thickness
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              personName = value.trim();
                            },
                            validator: Validator.personNameValidator,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  trainFromGallery(
                                      formKey: _formKey,
                                      detectController: detectController,
                                      trainController: trainController,
                                      personName: personName.trim(),
                                      fileName: fileName);
                                }
                              },
                              buttonName: 'Gallery',
                              icon: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                            ),
                            CustomButton(
                              buttonName: 'Capture',
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  captureAndTrainImage(
                                      formKey: _formKey,
                                      context: context,
                                      detectController: detectController,
                                      trainController: trainController,
                                      personName: personName,
                                      fileName: fileName);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              buttonName: 'Delete',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {

                                deleteStudent(2);
                                if (_formKey.currentState!.validate()) {
                                  deleteNameFromSharedPreferences(
                                      textFieldController,
                                      personName,
                                      fileName);
                                }
                              },
                            ),
                            CustomButton(
                              buttonName: 'Register',
                              icon: const Icon(
                                Icons.app_registration,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                getKeysFromTestMap(fileName);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                    RegistrationScreen(faceDetector: faceDetector,
                                      interpreter: interpreter,cameras: cameras,)
                                ));
                              },
                            ),

                            CustomButton(
                              buttonName: 'Search',
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // getKeysFromTestMap(fileName);
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                //     ProfileScreen(faceDetector: faceDetector,
                                //       interpreter: interpreter,cameras: cameras,
                                //       originalName: 'Imran',
                                //       originalRollNumber: 19702036.toString(),
                                //       originalSemester: 8.toString(),
                                //       originalSession: '2018-19',
                                //
                                //     )
                                // ));

                                Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchStudent(
                                  faceDetector: faceDetector,
                                  interpreter: interpreter,
                                  cameras: cameras,
                                )));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (detectState is LoadingState)
                    const CircularProgressIndicator(),

                  if (detectState is SuccessState)
                    SizedBox(
                      ///container
                      height: 200,
                      width: 100,
                      child: ListView.builder(
                        itemCount: detectState.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final img.Image image = detectState.data[index];
                          final Uint8List uint8List =
                              convertImageToUint8List(image);

                          return SizedBox(
                            ///container
                            width: 112,
                            height: 112,
                            // margin: const EdgeInsets.all(8.0),
                            child: Image.memory(
                              uint8List,
                              width: 112.0,
                              height: 112.0,
                              // fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(
                    height: 10.0,
                  ),

                  if (recognizeState is SuccessState &&
                      detectState is SuccessState)
                    Center(
                      child: Text(
                        recognizeState.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (recognizeState is ErrorState &&
                      detectState is SuccessState)
                    Center(
                      child: Text(
                        recognizeState.errorMessage,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (detectState is ErrorState && recognizeState is ErrorState)
                    Center(
                      child: Text(
                        recognizeState.errorMessage,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (detectState is ErrorState)
                    Center(
                      child: Text(
                        detectState.errorMessage,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // if(trainState is ErrorState && detectState is ErrorState)
                  //   Center(child: Text(trainState.errorMessage,
                  //     style: const  TextStyle(
                  //       fontSize: 25,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteStudent(int id) async {
    final url = Uri.parse('http://192.168.0.106:8000/api/students/$id/');

    final response = await http.delete(url);

    if (response.statusCode == 204) {
      print('Student deleted successfully');
    } else {
      print('Failed to delete student');
    }
  }


  Future<void> deleteJsonFromSharedPreferences(String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the key exists
    bool keyExists = prefs.containsKey(nameOfJsonFile);

    if (keyExists) {
      // Delete the key (file) from SharedPreferences
      prefs.remove(nameOfJsonFile);
      print('deleted $nameOfJsonFile');
    } else {
      print('$nameOfJsonFile does not exist in SharedPreferences.');
    }
  }

  Future<void> getKeysFromTestMap(String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonTestMap = prefs.getString(nameOfJsonFile);

    if (jsonTestMap != null) {
      // Parse the JSON string into a Map
      Map<String, dynamic> testMap = jsonDecode(jsonTestMap);

      // Get the keys from the Map
      List<String> keys = testMap.keys.toList();

      keys.forEach((key) {
        // Access the corresponding value for each key
        dynamic value = testMap[key];

        print('$key: $value');
        // for(int i = 0; i<value.length;i++){
        //   print(' ${value[i]}');
        // }
      });
    } else {
      print('$nameOfJsonFile is empty or not found in SharedPreferences.');
      // print('testMap is empty or not found in SharedPreferences.');
    }
  }

  Future<void> deleteNameFromSharedPreferences(
      TextEditingController textEditingController,
      String name,
      String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString(nameOfJsonFile);
    if (jsonString != null) {
      // Parse the JSON string into a Map
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Remove the desired key from the Map

      jsonMap.remove(name);

      textEditingController.clear();

      // Serialize the Map back into a JSON string
      String updatedJsonString = json.encode(jsonMap);

      // Save the updated JSON string back into SharedPreferences

      prefs.setString(nameOfJsonFile, updatedJsonString);

      Fluttertoast.showToast(msg: '$name removed');

      print('Deleted $name from $nameOfJsonFile');
      name = '';
    } else {
      Fluttertoast.showToast(msg: '$name not found');
      print('Name does not exist in $nameOfJsonFile');
      name = '';
    }
  }

  Future<void> trainFromGallery(
      {formKey,
      detectController,
      trainController,
      personName,
      fileName}) async {
    if (formKey.currentState!.validate()) {
      //detect face and train the mobilefacenet model
      await detectController
          .detectFacesFromImages(faceDetector, 'Train from gallery')
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

        await trainController.pickImagesAndTrain(
            personName, interpreter, imgList, fileName);

        personName = '';

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
      detectController,
      trainController,
      personName,
      fileName}) async {
    // if (formKey.currentState!.validate()) {

    final List<XFile>? capturedImages = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraCaptureScreen(
                cameras: cameras,
              )),
    );

    if (capturedImages != null) {
      await detectController
          .detectFacesFromImages(
              faceDetector, 'Train from captures', capturedImages)
          .then((imgList) async {
        final stopwatch = Stopwatch()..start();

        await trainController.pickImagesAndTrain(
            personName, interpreter, imgList, fileName);

        // personName = '';

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Detection and Training Execution Time: $elapsedSeconds seconds');
      });
    }
  }

  Future<void> burstShotTraining(
      {context,
      detectController,
      trainController,
      personName,
      fileName}) async {
    final Map<String, dynamic> mapCapturedImages = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraBurstCaptureScreen(
                cameras: cameras,
              )),
    );

    // {'images':capturedImages, 'camController': controller}
    List<CameraImage> camImages = mapCapturedImages['images'];
    CameraController camController = mapCapturedImages['camController'];

    // List<dynamic> imgList =[];
    List<InputImage> inputImageList = [];
    List<img.Image> imgImageList = [];

    for (var i = 0; i < camImages.length; i++) {
      //For detecting faces
      InputImage inputImage =
          convertCameraImageToInputImage(camImages[i], camController);

      //For recognizing faces
      img.Image imgImage = convertCameraImageToImgImage(
          camImages[i], camController.description.lensDirection);

      inputImageList.add(inputImage);
      imgImageList.add(imgImage);

      //detects faces from each image. one loop for one image

      //listing all the face images one by one
      // imgList.add(faceDetected[0]);
    }
    // print('The imglist length is ${imgList.length}');
    await detectController
        .detectFromLiveFeedForRecognition(
            inputImageList, imgImageList, faceDetector)
        .then((imgList) async {
      // passing the list of all face images for saving in database.
      await trainController.pickImagesAndTrain(
          personName, interpreter, imgList, fileName);
    });
  }

  Future<void> recognizeImage(
      {detectController, recognizeController, fileName}) async {
    await detectController
        .detectFacesFromImages(faceDetector, 'Recognize from gallery')
        .then((value) async {
      //For collection of data for FAR and FRR
      for (var i = 0; i < value.length; i++) {
        final stopwatch = Stopwatch()..start();

        await recognizeController.pickImagesAndRecognize(
            value[i], interpreter, isolateInterpreter, fileName);

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Recognition from image Execution Time: $elapsedSeconds seconds');
      }
    });
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Future<void> goToLiveFeedScreen(context, detectController, fileName) async {
  //   List<CameraDescription> cameras = await availableCameras();

  //   Navigator.push(
  //     context,
  //     // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
  //     MaterialPageRoute(
  //       builder: (context) => LiveFeedScreen(
  //         isolateInterpreter: widget.isolateInterpreter,
  //         // detectionController: detectController,
  //         faceDetector: widget.faceDetector,
  //         cameras: cameras,
  //         interpreter: widget.interpreter,
  //         studentFile: fileName,
  //         family: 'family',
  //         // family: 'Test',
  //         nameOfScreen: 'Home',

  //         // livenessInterpreter: livenessInterpreter,
  //       ),
  //     ),
  //   );
  // }
}
