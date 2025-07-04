import 'package:flutter/material.dart';
import '../routes.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  _NewPatientScreenState createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int? age;
  String tooth = '';

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('New Patient')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (v) => age = int.tryParse(v!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tooth Number'),
                onSaved: (v) => tooth = v!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  // TODO: save patient, then navigate to profile
                  Navigator.pushNamed(ctx, Routes.patientProfile);
                },
                child: Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
