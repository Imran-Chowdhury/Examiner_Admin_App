
import 'package:face_roll_student/core/constants/constants.dart';
import 'package:face_roll_student/features/profile/presentaion/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/train_face/presentation/views/home_screen.dart';



void main() {
  WidgetsFlutterBinding
      .ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: ColorConst.backgroundColor,
      ),
      // theme: ThemeData( scaffoldBackgroundColor: Colors.lightGreenAccent,),
      home: SafeArea(child: HomeScreen()),
      // home: SafeArea(child: ProfileScreen()),
      // home: const SafeArea(child: RegistrationScreen()),

      // home: SafeArea(child: CourseSelectionScreen()),
      // home: SafeArea(child: SemesterSelectionScreen()),
    );
  }
}
