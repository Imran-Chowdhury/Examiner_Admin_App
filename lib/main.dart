

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0XFFfcfcfc),
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
