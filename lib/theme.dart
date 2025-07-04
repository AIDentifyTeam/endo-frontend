import 'package:flutter/material.dart';

class AppColors {
  static const newDiagnosis = LinearGradient(
    colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
  );
  static const history = LinearGradient(
    colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
  );
  static const research = LinearGradient(
    colors: [Color(0xFFb24592), Color(0xFFf15f79)],
  );
}

final appTheme = ThemeData(
  primaryColor: Colors.teal,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
);