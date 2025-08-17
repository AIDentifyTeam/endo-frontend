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
  final TextEditingController _chiefComplaintTextController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  final Map<String, dynamic> _answers = {};
  bool _submitting = false;
  String? _toothNumberError;
  late Patient _patient;

  // Steps: 0 = Patient History, 1 = Clinical & Radiographic
  int _currentStep = 0;

  // IDs from Excel / model
  static const String _chiefId = 'chief_complaint';
  static const String _pId = 'P';
  static const List<String> _qToXIds = ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'];

  bool get _onHistory => _currentStep == 0;

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

  // ---------- Utilities (by ID, answers stay keyed by TITLE) ----------
  DiagnosisQuestion? _findById(String id) {
    for (final q in diagnosisQuestions) {
      if (q.id == id) return q;
    }
    return null;
  }

  String? _answerValueForId(String id) {
    final q = _findById(id);
    if (q == null) return null;
    final v = _answers[q.title];
    return v is String ? v : null;
  }

  bool get _pIsYes => _answerValueForId(_pId) == 'Yes';

  // -------------------- Page splits --------------------
  List<DiagnosisQuestion> get _historyQuestions {
    final List<DiagnosisQuestion> out = [];
    final cc = _findById(_chiefId);
    if (cc != null) out.add(cc);

    final p = _findById(_pId);
    if (p != null) out.add(p);

    if (_pIsYes) {
      for (final id in _qToXIds) {
        final q = _findById(id);
        if (q != null) out.add(q);
      }
    }
    return out;
  }

  List<DiagnosisQuestion> get _evaluationQuestions {
    final idsHistory = <String>{_chiefId, _pId, ..._qToXIds};
    return diagnosisQuestions.where((q) => !idsHistory.contains(q.id)).toList();
  }

  List<DiagnosisQuestion> get _activeQuestions =>
      _onHistory ? _historyQuestions : _evaluationQuestions;

  // -------------------- Validation for Next --------------------
  bool _historyValid() {
    final p = _findById(_pId);

    // If P isn't present yet, just require Chief Complaint (if it exists)
    if (p == null) {
      final cc = _findById(_chiefId);
      if (cc == null) return true;
      return _answers[cc.title] != null;
    }

    // Require P
    final pAnswer = _answers[p.title];
    if (pAnswer == null || (pAnswer is String && pAnswer.isEmpty)) return false;

    // If P == Yes, require all present Q..X
    if (_pIsYes) {
      for (final id in _qToXIds) {
        final q = _findById(id);
        if (q != null) {
          final val = _answers[q.title];
          if (val == null || (val is String && val.isEmpty)) return false;
        }
      }
    }
    return true;
  }

  // -------------------- Step navigation with scroll-to-top --------------------
  void _goToStep(int step) {
    setState(() => _currentStep = step);
    // Reset scroll position to the very top of the CustomScrollView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  // -------------------- Media pick (Page 1 only) --------------------
  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
        if (kIsWeb) {
          picked.readAsBytes().then((bytes) {
            if (!mounted) return;
            setState(() => _webImageBytes = bytes);
          });
        }
      });
    }
  }

  // -------------------- Answer helpers --------------------
  void _clearAnswer(String title) {
    setState(() {
      _answers.remove(title);
      final cc = _findById(_chiefId);
      if (cc != null && title == cc.title) {
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

  // -------------------- Submit --------------------
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

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final totalQuestions = _activeQuestions.length;

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

            // Slim progress bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: LinearProgressIndicator(
                  value: _onHistory ? 0.5 : 1.0,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF7E22CE),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Page header (nice, minimal)
            SliverToBoxAdapter(
              child: _buildPageHeader(
                title: _onHistory ? 'Patient History' : 'Clinical & Radiographic Evaluation',
                subtitle: _onHistory
                    ? 'Answer a few short questions about symptoms and history.'
                    : 'Record clinical tests and radiographic findings.',
              ),
            ),

            // Patient card (keep on both steps)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PatientInfoCard(
                  patient: _patient,
                  toothNumber: _toothNumberController.text,
                ),
              ),
            ),

            // Tooth & Photo — show ONLY on Page 1
            if (_onHistory)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildToothAndPhotoCard(),
                    const SizedBox(height: 8),
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

            // Questions (for the active step)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final q = _activeQuestions[index];
                  final isMulti = q.id == 'etiology_assessment';
                  return _buildQuestionCard(
                    q,
                    isMulti: isMulti,
                    displayIndex: index + 1,
                    totalCount: totalQuestions,
                  );
                },
                childCount: totalQuestions,
              ),
            ),

            // Navigation buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (!_onHistory)
                      _buildNavigationButton('Back', () {
                        _goToStep(0);
                      }),
                    const Spacer(),
                    _onHistory
                        ? _buildNavigationButton(
                            'Next',
                            _historyValid()
                                ? () {
                                    // If P not Yes, wipe Q..X answers before moving
                                    final p = _findById(_pId);
                                    if (p == null || !_pIsYes) {
                                      for (final id in _qToXIds) {
                                        final q = _findById(id);
                                        if (q != null) _answers.remove(q.title);
                                      }
                                    }
                                    _goToStep(1);
                                  }
                                : null,
                          )
                        : _buildNavigationButton(
                            _submitting ? 'Submitting...' : 'Submit',
                            _submitting ? null : _submitDiagnosis,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------
  Widget _buildPageHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // **Only shown on Page 1**
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
            const Text(
              "Enter Tooth Number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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

  Widget _buildQuestionCard(
    DiagnosisQuestion q, {
    bool isMulti = false,
    required int displayIndex,
    required int totalCount,
  }) {
    final isChiefComplaint = q.id == _chiefId;

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
            Text(
              'Question $displayIndex/$totalCount',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${q.title}${q.isOptional ? ' (Optional)' : ''}',
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
            const SizedBox(height: 8),
            Text(q.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 12),

            if (isMulti)
              ...q.options.map((option) => CheckboxListTile(
                    title: Text(option),
                    enabled: (_answers[q.title] as List?)?.contains('Not sure') == true &&
                            option != 'Not sure'
                        ? false
                        : true,
                    value: (_answers[q.title] as List?)?.contains(option) ?? false,
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
                        if (isChiefComplaint && val == 'No') {
                          _answers.remove('Chief Complaint Text');
                          _chiefComplaintTextController.clear();
                        }
                      });
                    },
                  )),

            if (isChiefComplaint && _answers[q.title] == 'Yes') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _chiefComplaintTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Describe the chief complaint',
                  border: OutlineInputBorder(),
                ),
                onChanged: (txt) {
                  setState(() {
                    _answers['Chief Complaint Text'] = txt;
                  });
                },
              ),
            ],

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
