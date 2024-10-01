

import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/customTile.dart';
import '../../../registraion/presentation/views/registration_screen.dart';
import '../../../search/presentaion/views/search_screen.dart';



class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}


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
    var interpreterOptions = InterpreterOptions()
      ..addDelegate(GpuDelegateV2()); //good

    return await tf_lite.Interpreter.fromAsset('assets/facenet_512.tflite',
        options: interpreterOptions);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.018),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: <Widget>[

                    SizedBox(height: screenHeight * 0.057,),

                    Center(
                      child: Container(
                        height: screenHeight*0.24, //80
                        width: screenWidth*0.8, //180
                        decoration:const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/vector.jpg',
                            ),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.057,),
                    //  SizedBox(height: screenHeight*0.115,),
                    const Text(
                      'Examiner-Admin',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.0115),
                    const Text(
                      'Hello, Student!',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    // SizedBox(height: screenHeight * 0.0115),
                    const Text(
                      "Let's Get Started or Manage Profile!",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        CustomTile(
                          color: const Color(0xFFcabbe9),
                          tileName: 'Register',
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 80, // Set the size of the icon
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    RegistrationScreen(
                                      faceDetector: faceDetector,
                                      interpreter: interpreter,
                                      cameras: cameras,)
                                ),
                            );
                          },
                        ),
                        SizedBox(
                          height: screenHeight * 0.3,
                          width: screenWidth * 0.02,),
                        CustomTile(

                          // color: const Color(0xFFffff4e0),
                          color: const Color(0xFFffe2d4),
                          tileName: 'Search',
                          icon: const Icon(
                            Icons.search_sharp,
                            weight: 150,
                            size: 80,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    SearchStudent(
                                      faceDetector: faceDetector,
                                      interpreter: interpreter,
                                      cameras: cameras,
                                    )));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }
}
