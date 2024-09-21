import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_roll_student/core/base_state/search_student_state.dart';
import 'package:face_roll_student/core/utils/background_widget.dart';
import 'package:face_roll_student/features/search/presentaion/riverpod/search_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

import '../../../profile/presentaion/views/profile_screen.dart';

// SearchStudent widget
// class SearchStudent extends ConsumerStatefulWidget {
//   // const SearchStudent({Key? key}) : super(key: key);
//   SearchStudent({required this.faceDetector, required this.interpreter,
//     required this.cameras});
//   final FaceDetector faceDetector;
//   final tf_lite.Interpreter interpreter;
//   final List<CameraDescription> cameras;
//
//   @override
//   _SearchStudentState createState() => _SearchStudentState();
// }
//
// class _SearchStudentState extends ConsumerState<SearchStudent> {
//   final TextEditingController rollEditingController = TextEditingController();
//
//   @override
//   void dispose() {
//     rollEditingController.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     SearchNotifier searchController = ref.watch(searchProvider.notifier);
//     final searchState = ref.watch(searchProvider);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           BackgroundContainer(),
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 150),
//                 child: buildTextFormField(
//                   hintText: 'Roll Number',
//                   controller: rollEditingController,
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) => rollEditingController.text = value.trim(),
//                   validator: (value) => value == null || value.isEmpty
//                       ? 'Please enter your roll number'
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   final rollNumber = rollEditingController.text;
//                   if (rollNumber.isNotEmpty) {
//                    searchController.getAStudent(rollNumber);
//                     print('Searching for student with roll number: $rollNumber');
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter a roll number')),
//                     );
//                   }
//                 },
//                 icon: const Icon(Icons.arrow_forward),
//                 label: const Text('Go'),
//               ),
//
//               // Conditionally display UI based on the state
//               Expanded(
//                 child: Builder(
//                   builder: (context) {
//                     if (searchState is SearchStudentLoadingState) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (searchState is SearchStudentSuccessState) {
//                       return ListView.builder(
//                         itemCount: searchState.data.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: (){
//                               print(searchState.data);
//                               Navigator.push(context, MaterialPageRoute(builder: (context)=>
//                                   ProfileScreen(faceDetector: widget.faceDetector,
//                                     interpreter: widget.interpreter,cameras: widget.cameras,
//                                     originalName: searchState.data[index]['name'],
//                                     originalRollNumber: searchState.data[index]['roll_number'].toString(),
//                                     originalSemester: searchState.data[index]['semester'].toString(),
//                                     originalSession: searchState.data[index]['session'],
//                                     // originalSession: '2018-19',
//                                     uint8list: List<int>.from(searchState.data[index]['image']), // Convert to List<int> if needed
//                                   )
//                               ));
//                             },
//                             child: ListTile(
//                               title: Text(searchState.data[index]['name'],
//                                 style:const TextStyle(color: Colors.white70) ,),
//                             ),
//                           );
//                         },
//                       );
//                     } else if (searchState is SearchStudentErrorState) {
//                      String errMessage =  searchState.errorMessage;
//                       return Center(
//                         child: Text(errMessage),
//                       );
//                     } else {
//                       return const SizedBox(); // Default empty state
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
class SearchStudent extends ConsumerStatefulWidget {
  SearchStudent({
    required this.faceDetector,
    required this.interpreter,
    required this.cameras,
  });

  final FaceDetector faceDetector;
  final tf_lite.Interpreter interpreter;
  final List<CameraDescription> cameras;

  @override
  _SearchStudentState createState() => _SearchStudentState();
}

class _SearchStudentState extends ConsumerState<SearchStudent> {
  final TextEditingController rollEditingController = TextEditingController();
  final TextEditingController semesterEditingController = TextEditingController();

  // Search type selection: 'roll_number' or 'semester'
  String selectedFilter = 'roll_number';

  @override
  void dispose() {
    rollEditingController.dispose();
    semesterEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SearchNotifier searchController = ref.watch(searchProvider.notifier);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      body: Stack(
        children: [
          BackgroundContainer(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: _buildSearchFilter(),
              ),
              const SizedBox(height: 16),

              // Display appropriate input field based on the selected filter
              if (selectedFilter == 'roll_number') ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: buildTextFormField(
                    hintText: 'Roll Number',
                    controller: rollEditingController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => rollEditingController.text = value.trim(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your roll number'
                        : null,
                  ),
                ),
              ] else if (selectedFilter == 'semester') ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: buildTextFormField(
                    hintText: 'Semester',
                    controller: semesterEditingController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => semesterEditingController.text = value.trim(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the semester'
                        : null,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Search button
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedFilter == 'roll_number') {
                    // Search by roll number
                    final rollNumber = rollEditingController.text;
                    if (rollNumber.isNotEmpty) {
                      searchController.getAStudent(rollNumber);
                      print('Searching for student with roll number: $rollNumber');
                    } else {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Please enter a roll number')),
                      // );
                      Fluttertoast.showToast(msg: 'Please enter a roll number');
                    }
                  } else if (selectedFilter == 'semester') {
                    // Search by semester
                    final semester = semesterEditingController.text;
                    if (semester.isNotEmpty) {
                      searchController.getStudentBySemester(semester);
                      print('Searching for students in semester: $semester');
                    } else {
                      Fluttertoast.showToast(msg: 'Please enter a semester');
                    }
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),

              // Conditionally display UI based on the state
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (searchState is SearchStudentLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (searchState is SearchStudentSuccessState) {
                      return ListView.builder(
                        itemCount: searchState.data.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    faceDetector: widget.faceDetector,
                                    interpreter: widget.interpreter,
                                    cameras: widget.cameras,
                                    originalName: searchState.data[index]['name'],
                                    originalRollNumber: searchState.data[index]['roll_number'].toString(),
                                    originalSemester: searchState.data[index]['semester'].toString(),
                                    originalSession: searchState.data[index]['session'],
                                    uint8list: List<int>.from(searchState.data[index]['image']),
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(
                                searchState.data[index]['name'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (searchState is SearchStudentErrorState) {
                      String errMessage = searchState.errorMessage;
                      return Center(
                        child: Text(errMessage),
                      );
                    } else {
                      return const SizedBox(); // Default empty state
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dropdown to toggle between search filters
  Widget _buildSearchFilter() {
    return DropdownButton<String>(
      value: selectedFilter,
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(
          value: 'roll_number',
          child: Text('Search by Roll Number'),
        ),
        DropdownMenuItem(
          value: 'semester',
          child: Text('Search by Semester'),
        ),
      ],
      onChanged: (String? newValue) {
        setState(() {
          selectedFilter = newValue!;
        });
      },
    );
  }
}


  Widget buildTextFormField({
    required String hintText,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    // required bool enabled,
    required TextEditingController controller,

  }) {
    return TextFormField(
      controller: controller,
      // enabled: enabled,
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

