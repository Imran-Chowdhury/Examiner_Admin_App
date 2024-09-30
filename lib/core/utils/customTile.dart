


import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final VoidCallback onPressed;
  final String tileName;
  final Icon icon;
  final color;

  const CustomTile({
    super.key,
    required this.onPressed,
    required this.tileName,
    required this.icon,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
          onTap: onPressed,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            elevation: 8,
            color: color,
            child: Container(
              width: (0.45 * width),
              height: (0.18 * height),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: color,
              ),
              child: Center(  // Centers the column horizontally and vertically
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Centers vertically within the Column

                  children: [
                   icon,
                    const SizedBox(height: 8), // Add space between icon and text
                    Text(
                      tileName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

  }
}

