import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/patient_profile.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';

void main() => runApp(EndoApp());

class EndoApp extends StatelessWidget {
  const EndoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EndoApp',
      theme: appTheme,
      initialRoute: Routes.login,
      routes: Routes.map,
      onGenerateRoute: (settings) {
        if (settings.name == Routes.patientProfile) {
          final patient = settings.arguments as Patient;
          return MaterialPageRoute(
            builder: (context) => PatientProfileScreen(patient: patient),
          );
        }
        // Optional: fallback
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Unknown route')),
          ),
        );
      },
    );
  }
}
