import 'package:flutter/material.dart';

class PatientAvatar extends StatelessWidget {
  final String initials;
  final bool isSelected;

  const PatientAvatar({super.key, 
    required this.initials,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext ctx) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
      child: Text(initials, style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }
}
