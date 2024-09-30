
import 'package:camera/camera.dart';
import 'package:face_roll_student/core/base_state/search_student_state.dart';
import 'package:face_roll_student/core/utils/customTextFormField.dart';
import 'package:face_roll_student/core/utils/nameCard.dart';
import 'package:face_roll_student/core/utils/validators/validators.dart';
import 'package:face_roll_student/features/search/presentaion/riverpod/search_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../profile/presentaion/views/profile_screen.dart';


class SearchStudent extends ConsumerStatefulWidget {
  const SearchStudent({super.key,
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
  String selectedFilter = 'Roll'; // Default filter

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

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;



    return Scaffold(
      floatingActionButton: Padding(
        padding:  EdgeInsets.only(right: screenWidth*0.05,bottom: screenHeight*0.05 ),
        child: SizedBox(
          width: 80.0,
          height: 80.0,
          child: FloatingActionButton(
            onPressed: () {
              // Action when the button is pressed
              search(searchController);
            },
            elevation: 10.0,
            backgroundColor: const Color(0xFFB37BA4),
            shape: const CircleBorder(),
            child:  const Icon(Icons.search_sharp, size: 40.0,color: Colors.white,),
          ),
        ),
      ),
      appBar: AppBar(
        title:const  Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.018),
        child: Stack(
          children: [Column(
            children: [


              // Display appropriate input field based on the selected filter
              if (selectedFilter == 'Roll') ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 50, // Adjust the flex for text field
                        child: customTextFormField(
                          hintText: 'Roll Number',
                          controller: rollEditingController,
                          keyboardType: TextInputType.number,
                          height: screenHeight,
                          onChanged: (value) => rollEditingController.text = value,
                          validator: Validator.rollNumberValidator,
                        ),
                      ),
                      Expanded(
                        flex: 5, // Adjust the flex for icon button
                        child: IconButton(
                          icon: const Icon(
                              Icons.filter_list, color: Colors.black,
                            size: 40,
                          ),
                          onPressed: () {
                            showFilterDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (selectedFilter == 'Semester') ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: customTextFormField(
                          hintText: 'Semester',
                          controller: semesterEditingController,
                          keyboardType: TextInputType.number,
                          height: screenHeight,
                          onChanged: (value) => semesterEditingController.text = value,
                          validator: Validator.semesterValidator,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: IconButton(
                          icon: const Icon(Icons.filter_list, color: Colors.black, size: 40,),
                          onPressed: () {
                            showFilterDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

               SizedBox(height: screenHeight*0.01),


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

                            child: NameCard(
                                name: searchState.data[index]['name'],
                              rollNumber: searchState.data[index]['roll_number'].toString(),
                              semester: searchState.data[index]['semester'].toString(),
                            ),
                          );
                        },
                      );
                    } else if (searchState is SearchStudentErrorState) {
                      String errMessage = searchState.errorMessage;
                      return Column(
                        children: [
                          SizedBox(height: screenHeight*0.1),
                          Center(
                            child: Container(
                              height: screenHeight*0.24, //80
                              width: screenWidth*0.8, //180
                              decoration:const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/error.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              errMessage,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          )

                        ],
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
      ),
    );
  }
  void search(SearchNotifier searchController){
    if (selectedFilter == 'Roll') {
      final rollNumber = rollEditingController.text.trim();
      if (rollNumber.isNotEmpty) {
        searchController.getAStudent(rollNumber);
        // print('Searching for student with roll number: $rollNumber');
      } else {
        Fluttertoast.showToast(msg: 'Please enter a roll number');
      }
    } else if (selectedFilter == 'Semester') {
      final semester = semesterEditingController.text.trim();
      if (semester.isNotEmpty) {
        searchController.getStudentBySemester(semester);
        // print('Searching for students in semester: $semester');
      } else {
        Fluttertoast.showToast(msg: 'Please enter a semester');
      }
    }
  }
  // Function to show the filter dialog with radio buttons
  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Search Filter'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Roll Number'),
                    value: 'Roll',
                    groupValue: selectedFilter,
                    onChanged: (String? value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Semester'),
                    value: 'Semester',
                    groupValue: selectedFilter,
                    onChanged: (String? value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
