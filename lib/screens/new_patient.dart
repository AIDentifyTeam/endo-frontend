import 'package:endo_frontend/services/api_service.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:flutter/material.dart';
import '../routes.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});
  @override
  _NewPatientScreenState createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clinicIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedDate; // optional
  String? _selectedSex; // optional
  bool _autoGenerateId = true; // checkbox state

  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final _phoneRegex = RegExp(r'^[0-9+\-() ]{7,}$');

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _optionalEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    return _emailRegex.hasMatch(s)
        ? null
        : 'Failed to create new patient, please enter a valid phone number/email.';
  }

  String? _optionalPhone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    return _phoneRegex.hasMatch(s)
        ? null
        : 'Failed to create new patient, please enter a valid phone number/email.';
  }

  InputDecoration _dec(String label, {bool required = false, String? hint}) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          children: required
              ? const [
                  TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                ]
              : const [],
        ),
      ),
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const MainDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF4FF), Color(0xFFFFFFFF), Color(0xFFEEF2FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: 'New Patient',
                subtitle: 'Create and register a new patient profile',
                icon: Icons.person_add,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Information',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _autoGenerateId,
                                  onChanged: (v) => setState(() {
                                    _autoGenerateId = v ?? false;
                                    if (_autoGenerateId) {
                                      _clinicIdController.clear();
                                    }
                                  }),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Auto-generate Patient ID',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 12.0, bottom: 8),
                              child: Text(
                                'If checked, an ID will be generated automatically. You do not need to enter one.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),

                            // ID Field
                            TextFormField(
                              controller: _clinicIdController,
                              enabled: !_autoGenerateId,
                              decoration: _dec(
                                'Patient ID (Clinic system)',
                                hint: _autoGenerateId
                                    ? 'Auto-generation enabled'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration:
                                        _dec('First Name', required: true),
                                    validator: _required,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration:
                                        _dec('Last Name', required: true),
                                    validator: _required,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _dec('Phone'),
                              validator: _optionalPhone,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _dec('Email'),
                              validator: _optionalEmail,
                            ),
                            const SizedBox(height: 12),

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
                                        setState(() =>
                                            _selectedDate = picked);
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration:
                                          _dec('Date of Birth'),
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
                                    decoration: _dec('Sex'),
                                    items: const [
                                      'Male',
                                      'Female',
                                      'Other'
                                    ]
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedSex = v),
                                  ),
                                ),
                              ],
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  try {
                                    final patient = await ApiService()
                                        .createPatient(
                                      firstName: _firstNameController.text
                                          .trim(),
                                      lastName: _lastNameController.text
                                          .trim(),
                                      patientId: _autoGenerateId
                                          ? null
                                          : (_clinicIdController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _clinicIdController.text
                                                  .trim()),
                                      email: _emailController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _emailController.text.trim(),
                                      phone: _phoneController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _phoneController.text.trim(),
                                      sex: _selectedSex,
                                      birthDate: _selectedDate == null
                                          ? null
                                          : _selectedDate!
                                              .toIso8601String()
                                              .split('T')
                                              .first,
                                    );

                                    if (patient != null) {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.patientProfile,
                                        arguments: patient,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Failed to create patient'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(e.toString())),
                                    );
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
