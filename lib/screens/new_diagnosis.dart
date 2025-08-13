// lib/screens/new_diagnosis_screen.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

import 'package:endo_frontend/widgets/patient_info_card.dart';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/diagnosis_result.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/data/diagnosis_questions.dart';
import 'package:endo_frontend/services/api_service.dart';

class NewDiagnosisScreen extends StatefulWidget {
  const NewDiagnosisScreen({super.key});

  @override
  State<NewDiagnosisScreen> createState() => _NewDiagnosisScreenState();
}

class _NewDiagnosisScreenState extends State<NewDiagnosisScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _toothNumberController = TextEditingController();
  // Short-text for Chief Complaint when "Yes"
  final TextEditingController _chiefComplaintTextController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  final Map<String, dynamic> _answers = {};
  bool _submitting = false;
  String? _toothNumberError;
  late Patient _patient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patient = ModalRoute.of(context)!.settings.arguments as Patient;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _toothNumberController.dispose();
    _chiefComplaintTextController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;

        if (kIsWeb) {
          picked.readAsBytes().then((bytes) {
            if (!mounted) return;
            setState(() {
              _webImageBytes = bytes;
            });
          });
        }
      });
    }
  }

  // Clear helpers
  void _clearAnswer(String title) {
    setState(() {
      _answers.remove(title);
      if (title == 'Chief Complaint') {
        _answers.remove('Chief Complaint Text');
        _chiefComplaintTextController.clear();
      }
    });
  }

  void _clearAllAnswers() {
    setState(() {
      _answers.clear();
      _chiefComplaintTextController.clear();
    });
  }

  Future<void> _submitDiagnosis() async {
    if (_toothNumberController.text.trim().isEmpty) {
      setState(() => _toothNumberError = 'Tooth number is required');
      return;
    } else {
      setState(() => _toothNumberError = null);
    }

    setState(() => _submitting = true);

    try {
      final visitId = await ApiService().createVisit(
        patientId: _patient.id,
        toothNumber: _toothNumberController.text,
        answers: _answers.map((k, v) => MapEntry(k, v is List ? v : v.toString())),
        pulpDiagnosis: _answers['Pulp Diagnosis'] ?? '',
        periapicalDisease: _answers['Periapical Disease'] ?? '',
        etiology: _answers['Etiology'] ?? '',
        toothImage: _selectedImage,
        webImageBytes: _webImageBytes,
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(
            visitId: visitId,
            patientName: '${_patient.firstName} ${_patient.lastName}',
          ),
        ),
      );

      if (!mounted) return;
      if (result == 'refresh') {
        Navigator.pop(context, 'refresh');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const MainDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeaderDelegate(
                child: const AppHeader(
                  title: 'New Diagnosis',
                  subtitle: 'Record patient case step-by-step',
                  icon: Icons.medical_services,
                ),
              ),
            ),

            // Patient + tooth/photo + action
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: PatientInfoCard(
                      patient: _patient,
                      toothNumber: _toothNumberController.text,
                    ),
                  ),
                  _buildToothAndPhotoCard(),
                  const SizedBox(height: 8),
                  // Single global action: Clear all answers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllAnswers,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear all answers'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Questions
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final q = diagnosisQuestions[index];

                  if (q.title == 'Etiology Assessment') {
                    return _buildQuestionCard(q, isMulti: true);
                  }

                  // Keep all questions visible regardless of Chief Complaint response
                  return _buildQuestionCard(q);
                },
                childCount: diagnosisQuestions.length,
              ),
            ),

            // Submit
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildNavigationButton(
                    _submitting ? 'Submitting...' : 'Submit',
                    _submitting ? null : _submitDiagnosis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToothAndPhotoCard() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Tooth & Photo',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const Text("Enter Tooth Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _toothNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "e.g., 24",
                errorText: _toothNumberError,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text("Upload Tooth Photo"),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              kIsWeb
                  ? _webImageBytes != null
                      ? Image.memory(_webImageBytes!, height: 100)
                      : const CircularProgressIndicator()
                  : Image.file(io.File(_selectedImage!.path), height: 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(DiagnosisQuestion q, {bool isMulti = false}) {
    final isChiefComplaint = q.title == 'Chief Complaint';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Question ${diagnosisQuestions.indexOf(q) + 1}/${diagnosisQuestions.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${q.title}${q.isOptional ? ' (Optional)' : ''}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
                Tooltip(
                    message: q.help,
                    child: const Icon(Icons.info_outline, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(q.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 12),

            // Answers
            if (isMulti)
              ...q.options.map((option) => CheckboxListTile(
                    title: Text(option),
                    enabled: (_answers[q.title] as List?)?.contains('Not sure') ==
                                true &&
                            option != 'Not sure'
                        ? false
                        : true,
                    value:
                        (_answers[q.title] as List?)?.contains(option) ?? false,
                    onChanged: (selected) {
                      setState(() {
                        final current = (_answers[q.title] as List?) ?? [];
                        if (selected == true) {
                          if (option == 'Not sure') {
                            _answers[q.title] = ['Not sure'];
                          } else {
                            current.remove('Not sure');
                            current.add(option);
                            _answers[q.title] = current;
                          }
                        } else {
                          current.remove(option);
                          _answers[q.title] = current;
                        }
                      });
                    },
                  ))
            else
              ...q.options.map((option) => RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: _answers[q.title],
                    onChanged: (val) {
                      setState(() {
                        _answers[q.title] = val;

                        // If Chief Complaint toggles to "No", clear the short-text
                        if (isChiefComplaint && val == 'No') {
                          _answers.remove('Chief Complaint Text');
                          _chiefComplaintTextController.clear();
                        }
                      });
                    },
                  )),

            // Short text when Chief Complaint == "Yes"
            if (isChiefComplaint && _answers[q.title] == 'Yes') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _chiefComplaintTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Describe the chief complaint',
                  hintText: 'e.g., Lingering pain to cold for 2 weeks',
                  border: OutlineInputBorder(),
                ),
                onChanged: (txt) {
                  setState(() {
                    _answers['Chief Complaint Text'] = txt;
                  });
                },
              ),
            ],

            // Per-question clear button
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _clearAnswer(q.title),
                icon: const Icon(Icons.clear),
                label: const Text('Clear answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String label, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7E22CE),
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(label),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 120;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: const Color(0xFFF8FAFC),
      elevation: 4,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
