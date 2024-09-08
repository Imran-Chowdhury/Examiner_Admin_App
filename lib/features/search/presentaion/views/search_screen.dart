import 'package:face_roll_student/core/base_state/search_student_state.dart';
import 'package:face_roll_student/core/utils/background_widget.dart';
import 'package:face_roll_student/features/search/presentaion/riverpod/search_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// SearchStudent widget
class SearchStudent extends ConsumerStatefulWidget {
  const SearchStudent({Key? key}) : super(key: key);

  @override
  _SearchStudentState createState() => _SearchStudentState();
}

class _SearchStudentState extends ConsumerState<SearchStudent> {
  final TextEditingController rollEditingController = TextEditingController();

  @override
  void dispose() {
    rollEditingController.dispose();
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
                padding: const EdgeInsets.only(top: 150),
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final rollNumber = rollEditingController.text;
                  if (rollNumber.isNotEmpty) {
                   searchController.getAStudent(rollNumber);
                    print('Searching for student with roll number: $rollNumber');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a roll number')),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Go'),
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
                          return ListTile(
                            title: Text(searchState.data[index]['name']),
                          );
                        },
                      );
                    } else if (searchState is SearchStudentErrorState) {
                     String errMessage =  searchState.errorMessage;
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
}
