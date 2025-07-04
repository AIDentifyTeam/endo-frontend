import 'package:flutter/material.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Profile')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: John Doe', style: TextStyle(fontSize: 18)),
            Text('Age: 29'),
            Text('Tooth No: 12'),
            SizedBox(height: 16),
            Text('Diagnosis: Pulpitis'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // expand to show full details, maybe a modal or new route
              },
              child: Text('View Full Details'),
            ),
          ],
        ),
      ),
    );
  }
}
