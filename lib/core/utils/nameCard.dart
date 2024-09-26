import 'package:flutter/material.dart';

class NameCard extends StatelessWidget {
  final String name;
  final String rollNumber;
  final String semester;

  const NameCard({
    Key? key,
    required this.name,
    required this.rollNumber,
    required this.semester
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // Optional: adds shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24, // Larger font size for the name
                fontWeight: FontWeight.bold, // Bold for emphasis
              ),
            ),
            const SizedBox(height: 8.0), // Spacing between name and roll number
            Text(
              rollNumber,
              style: const TextStyle(
                fontSize: 16, // Smaller font size for the roll number
                color: Colors.grey, // Grey color for the roll number
              ),
            ),
            const SizedBox(height: 8.0), // Spacing between name and roll number
            Text(
              'Semester $semester',
              style: const TextStyle(
                fontSize: 16, // Smaller font size for the roll number
                color: Colors.grey, // Grey color for the roll number
              ),
            ),
          ],
        ),
      ),
    );
  }
}