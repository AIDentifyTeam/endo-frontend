import 'package:flutter/material.dart';
import '../routes.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  _NewPatientScreenState createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _toothController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('New Patient'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ID
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone & Email
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // DOB & Sex
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(1990, 1, 1),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select'
                                  : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSex,
                          decoration: const InputDecoration(
                            labelText: 'Sex',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Male', 'Female', 'Other']
                              .map((sex) => DropdownMenuItem(
                                    value: sex,
                                    child: Text(sex),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSex = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tooth Number
                  TextFormField(
                    controller: _toothController,
                    decoration: const InputDecoration(
                      labelText: 'Tooth Number',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save & Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Add actual patient saving logic
                          Navigator.pushNamed(context, Routes.patientProfile);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
