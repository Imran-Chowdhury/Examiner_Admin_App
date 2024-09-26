
import 'package:face_roll_student/features/registraion/presentation/views/registration_screen.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/utils/background_widget.dart';
import '../../../../core/utils/customTile.dart';
import '../../../search/presentaion/views/search_screen.dart';



class HomeScreen extends ConsumerStatefulWidget {
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

  final _formKey = GlobalKey<FormState>();

//
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
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      'Dashboard',
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

                        customTile(
                          color: const Color(0xFFcabbe9),
                          buttonName: 'Register',
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
                                ));
                          },
                        ),
                        SizedBox(
                          height: screenHeight * 0.3,
                          width: screenWidth * 0.02,),
                        customTile(

                          // color: const Color(0xFFffff4e0),
                          color: const Color(0xFFffe2d4),
                          buttonName: 'Search',
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


                    // _LoginForm(formKey: _formKey,controller: controller,),


                    // SizedBox(
                    //   width: screenWidth*0.972, // Set your custom width
                    //   height: screenHeight*0.07, // Set your custom height
                    //   child: CustomButton(
                    //     screenHeight: screenHeight,
                    //     buttonName: 'Login',
                    //     color: UIConstants.color.loginBlue,
                    //     onpressed: (){
                    //
                    //       if (_formKey.currentState!.validate()) {
                    //
                    //         controller.login();
                    //         // print(controller.accessToken);
                    //
                    //
                    //       }
                    //     },
                    //   ),
                    // ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    // SizedBox(
                    //   width: screenWidth*0.972, // Set your custom width
                    //   height: screenHeight*0.07, // Set your custom height
                    //   child: CustomButton(
                    //     screenHeight: screenHeight,
                    //     buttonName: 'Continue with Google',
                    //     color: UIConstants.color.loginBlue,
                    //     onpressed: (){
                    //
                    //       googleController.googleLogin();
                    //
                    //
                    //
                    //
                    //     },
                    //   ),
                    // ),
                    // SizedBox(height: screenHeight*0.023),

                    // Center(
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Navigator.pushReplacement(context,MaterialPageRoute(
                    //         builder: (context) => SendPasswordResetEmailScreen(), // Instantiate the destination page widget
                    //       ),
                    //       );
                    //     },
                    //     child: const Text('Forgot password',
                    //       style: TextStyle(color: Colors.orange),),
                    //   ),
                    // ),

                    // SizedBox(height: screenHeight*0.023),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const  Text(
                    //       "Don't have an account?",
                    //       style: TextStyle(
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //     SizedBox(width: screenWidth*0.024),
                    //     GestureDetector(
                    //       onTap: () {
                    //         controller.emailField.clear();
                    //         controller.passwordField.clear();
                    //         Navigator.pushReplacement(
                    //           context,
                    //           MaterialPageRoute(builder: (context) => SignUpScreen()),
                    //         );
                    //       },
                    //       child: const  Text(
                    //         "Sign Up",
                    //         style: TextStyle(
                    //           color: Colors.orange,
                    //         ),
                    //       ),
                    //     ),
                    //
                    //     //  const SizedBox(width: 10.0,),
                    //     //  const ElevatedButton(onPressed: signOutGoogle, child: Text('Log out')),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            // if (state is LoadingState || googleState is LoadingState) // Conditionally display CircularProgressIndicator
            //   const Center(
            //     child: CircularProgressIndicator(),
            //   ),
          ]
      ),
    );
  }
}

//
//
//     return GestureDetector(
//       onTap: () {
//         // Hide the keyboard when tapped outside of the text field
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         // backgroundColor: const Color(0xFF3a3b45),
//         body: Column(
//           // mainAxisSize: MainAxisSize.min,
//           // mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Padding(
//               // padding: EdgeInsets.only(top: height*0.03,bottom: height*0.04),
//               padding: EdgeInsets.only(top: 50, bottom: 40),
//               // padding: EdgeInsets.only(top: (height*0.07)),
//               child: Center(
//                 child: Text(
//                   'Register',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 30.0,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//
//
//             const SizedBox(
//               height: 10.0,
//             ),
//
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//
//                   CustomButton(
//                     color:  const Color(0xFFcabbe9),
//                     buttonName: 'Register',
//                     icon: const  Icon(
//                       Icons.person_add_alt_1,
//                       color: Colors.white,
//                       size: 80, // Set the size of the icon
//                     ),
//                     onPressed: () {
//
//                       Navigator.push(context, MaterialPageRoute(builder: (context)=>
//                           RegistrationScreen(faceDetector: faceDetector,
//                             interpreter: interpreter,cameras: cameras,)
//                       ));
//                     },
//                   ),
//
//                   CustomButton(
//
// //                    color:  const Color(0xFFffff4e0),
//                     buttonName: 'Search',
//                     icon: const Icon(
//                       Icons.search,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchStudent(
//                         faceDetector: faceDetector,
//                         interpreter: interpreter,
//                         cameras: cameras,
//                       )));
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//
//     return GestureDetector(
//       onTap: () {
//         // Hide the keyboard when tapped outside of the text field
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         body: Column(
//           // mainAxisSize: MainAxisSize.min,
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           // Makes the column take minimum vertical space
//           children: [
//             Padding(
//               padding: EdgeInsets.only(top: screenHeight*0.2, right: screenWidth*0.7),
//               child:
//               const Text(
//                 'Home',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 30.0,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//
//
//             // SizedBox(
//             //   width: screenWidth*0.7,
//             //   height: screenHeight*0.0115,),
//             // const Text('We are happy to see you agent',
//             //   style: TextStyle(
//             //     color: Colors.grey,
//             //   ),),
//
//             SizedBox(height: screenHeight*0.1 ),
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CustomButton(
//                     color: const Color(0xFFcabbe9),
//                     buttonName: 'Register',
//                     icon: const Icon(
//                       Icons.person_add_alt_1,
//                       color: Colors.white,
//                       size: 80, // Set the size of the icon
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               RegistrationScreen(
//                                 faceDetector: faceDetector,
//                                 interpreter: interpreter,
//                                 cameras: cameras,
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//                   CustomButton(
//                     buttonName: 'Search',
//                     color: const Color(0xFFffff4e0),
//                     icon: const Icon(
//                       Icons.search,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SearchStudent(
//                                 faceDetector: faceDetector,
//                                 interpreter: interpreter,
//                                 cameras: cameras,
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }