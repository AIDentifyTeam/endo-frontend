import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback onPressed;

  const GradientButton({super.key, 
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
