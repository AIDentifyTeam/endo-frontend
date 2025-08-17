import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/patient_profile.dart';
import 'package:endo_frontend/app_navigator.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';
import 'services/api_service.dart';
import 'dart:ui';

void main() {
  // Prevent red error overlay for ApiException.
  FlutterError.onError = (details) {
    if (details.exception is ApiException) {
      // Already handled by the service (it navigates to /login).
      return;
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is ApiException) return true; // handled
    return false; // let other errors surface
  };

  runApp(const EndoApp());
}

class EndoApp extends StatelessWidget {
  const EndoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EndoApp',
      theme: appTheme,
      navigatorKey: appNavigatorKey, 
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
