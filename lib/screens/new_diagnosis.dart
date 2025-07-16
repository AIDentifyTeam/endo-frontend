import 'dart:io';
import 'package:endo_frontend/widgets/patient_info_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _toothNumberController = TextEditingController();
  File? _selectedImage;
  final Map<String, dynamic> _answers = {};
  bool _submitting = false;
  String? _toothNumberError;
  late Patient _patient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patient = ModalRoute.of(context)!.settings.arguments as Patient;
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _nextPage() {
    // Don't validate on the initial (tooth input) page
    if (_currentPage == 0 && _toothNumberController.text.trim().isEmpty) {
      setState(() {
        _toothNumberError = "Tooth number is required";
      });
      return;
    }
    if (_currentPage > 0 && _currentPage <= diagnosisQuestions.length) {
      final q = diagnosisQuestions[_currentPage - 1];
      if (!q.isOptional && _answers[q.title] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please answer: "${q.title}"')),
        );
        return;
      }
    }

    if (_currentPage < diagnosisQuestions.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _toothNumberError = null; // clear error if input is valid
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }


  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitDiagnosis() async {
    setState(() => _submitting = true);

    try {
      final visitId = await ApiService().createVisit(
        patientId: _patient.id,
        toothNumber: _toothNumberController.text,
        answers: _answers.map((k, v) => MapEntry(k, v.toString())),
        pulpDiagnosis: _answers['Pulp Diagnosis'] ?? '',
        periapicalDisease: _answers['Periapical Disease'] ?? '',
        etiology: _answers['Etiology'] ?? '',
        toothImage: _selectedImage,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Patient patient = ModalRoute.of(context)!.settings.arguments as Patient;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'New Diagnosis',
              subtitle: 'Record patient case step-by-step',
              icon: Icons.medical_services,
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: PatientInfoCard(patient: patient),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: diagnosisQuestions.length + 1,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SingleChildScrollView(
                        child: _buildToothAndPhotoStep(),
                      );
                    }

                    final q = diagnosisQuestions[index - 1];
                    return SingleChildScrollView(
                      child: _buildQuestionCard(q),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToothAndPhotoStep() {
    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Tooth Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                Image.file(_selectedImage!, height: 100),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _buildNavigationButton('Next', _nextPage),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(DiagnosisQuestion q) {
    int questionNumber = _currentPage;
    int totalQuestions = diagnosisQuestions.length;

    return Center(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 24, bottom: 32),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Question $questionNumber of $totalQuestions',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${q.title}${q.isOptional ? ' (Optional)' : ''}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                  Tooltip(message: q.help, child: const Icon(Icons.info_outline, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(q.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              ...q.options.map((option) {
                return RadioListTile(
                  title: Text(option),
                  value: option,
                  groupValue: _answers[q.title],
                  onChanged: (val) {
                    setState(() {
                      _answers[q.title] = val;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavigationButton('Back', _previousPage),
                  _buildNavigationButton(
                    _currentPage == diagnosisQuestions.length ? 'Finish' : 'Next',
                    _currentPage == diagnosisQuestions.length
                        ? (_submitting ? null : () => _submitDiagnosis())
                        : _nextPage,
                  ),
                ],
              ),
            ],
          ),
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
