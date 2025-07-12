import 'dart:io';
import 'package:endo_frontend/screens/diagnosis_result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/data/diagnosis_questions.dart';

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

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _nextPage() {
    if (_currentPage < diagnosisQuestions.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitDiagnosis() {
    print('Diagnosis submitted: $_answers');
    // Add summary screen or storage logic later
  }

  @override
  Widget build(BuildContext context) {
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
                    if (index == 0) return _buildToothAndPhotoStep();
                    final q = diagnosisQuestions[index - 1];
                    return _buildQuestionCard(q);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToothAndPhotoStep() {
    return Center(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 24),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter Tooth Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _toothNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., 24",
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
    int questionNumber = _currentPage; // Because page 0 is tooth/photo step
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
              /// Question Progress
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Question $questionNumber of $totalQuestions',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Question Title & Help
              Row(
                children: [
                  Expanded(
                    child: Text(
                      q.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: q.help,
                    child: const Icon(Icons.info_outline, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Question Text
              Text(
                q.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 16),

              /// Options
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

              /// Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavigationButton('Back', _previousPage),
                  _buildNavigationButton(
                    _currentPage == diagnosisQuestions.length ? 'Finish' : 'Next',
                    _currentPage == diagnosisQuestions.length
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiagnosisResultScreen(
                                  patientName: 'Dr. Smith', // You can make this dynamic later
                                  visitDate: DateTime.now().toIso8601String().split('T')[0],
                                  toothNumber: _toothNumberController.text,
                                  toothImage: _selectedImage,
                                  answers: _answers.map((key, value) => MapEntry(key.toString(), value.toString())),
                                ),
                              ),
                            );
                          }
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



  Widget _buildNavigationButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7E22CE),
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(text),
    );
  }
}
