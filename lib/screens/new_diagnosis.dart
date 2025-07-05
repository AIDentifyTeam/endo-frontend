import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import '../routes.dart';

class NewDiagnosisScreen extends StatelessWidget {
  const NewDiagnosisScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('New Diagnosis')),
      drawer: const MainDrawer(),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(ctx, Routes.newPatient),
              child: Text('Create New Patient'),
            ),
            ElevatedButton(
              onPressed: () {
                // pass to a patient selection flow
                Navigator.pushNamed(ctx, Routes.patientHistory);
              },
              child: Text('Select Existing Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
