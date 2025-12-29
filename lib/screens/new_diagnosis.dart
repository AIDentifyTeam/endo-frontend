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
import 'package:endo_frontend/widgets/tooth_picker.dart';
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
  final TextEditingController _chiefComplaintTextController =
      TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;

  /// All answers are stored by **question id** (not title).
  final Map<String, dynamic> _answers = {};

  bool _submitting = false;
  String? _toothNumberError;
  String? _selectedTooth;
  late Patient _patient;
  ToothNumberingSystem _numberingSystem = ToothNumberingSystem.fdi;

  // Steps: 0 = Patient History, 1 = Clinical & Radiographic
  int _currentStep = 0;

  // IDs from Excel / model
  static const String _chiefId = 'chief_complaint';
  static const String _pId = 'P';
  static const List<String> _qToXIds = ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'];

  bool get _onHistory => _currentStep == 0;

  // ----------- Edit mode wiring -----------
  bool _isEdit = false;
  int? _visitId;
  bool _removeExistingImage = false;
  String? _existingImageUrl; // optional (if your API returns it)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is Patient) {
      // CREATE FLOW
      _patient = args;
      _isEdit = false;
    } else if (args is Map) {
      // EDIT FLOW
      _isEdit = (args['mode'] == 'edit');
      _patient = args['patient'] as Patient;
      _visitId = args['visitId'] as int?;
      if (_isEdit && _visitId != null) {
        _loadForEdit(_visitId!);
      }
    } else {
      // Fallback - you can also assert here
      throw ArgumentError('Invalid arguments for NewDiagnosisScreen');
    }

    final initialTooth = _toothNumberController.text.trim();
    _selectedTooth = initialTooth.isEmpty ? null : initialTooth;
  }

  Future<void> _loadForEdit(int visitId) async {
    try {
      final data = await ApiService().fetchVisitById(visitId);

      // Prefill tooth number
      _toothNumberController.text = (data['tooth_number'] ?? '').toString();

      // Prefill answers
      final raw = data['answers'];
      if (raw is Map) {
        // coerce dynamic map to <String,dynamic>
        _answers.clear();
        raw.forEach((k, v) => _answers[k.toString()] = v);
      }

      // If your API returns existing image URL, show a hint (optional)
      _existingImageUrl = (data['tooth_image'] as String?);

      // If chief complaint text exists
      final ccText = _answers['chief_complaint_text'];
      if (ccText is String) {
        _chiefComplaintTextController.text = ccText;
      }

      setState(() {
        final value = _toothNumberController.text.trim();
        _selectedTooth = value.isEmpty ? null : value;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load visit: $e')));
      // Still allow editing of whatever we have.
    }
  }

  void _onToothSelected(String toothNumber) {
    setState(() {
      _selectedTooth = toothNumber;
      _toothNumberController.text = toothNumber;
      _toothNumberError = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _toothNumberController.dispose();
    _chiefComplaintTextController.dispose();
    super.dispose();
  }

  // ---------- Utilities (lookup by id) ----------
  DiagnosisQuestion? _findById(String id) {
    for (final q in diagnosisQuestions) {
      if (q.id == id) return q;
    }
    return null;
  }

  String? _answerValueForId(String id) {
    final v = _answers[id];
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
      // Add required first, then optional at the end
      final requiredQs = <DiagnosisQuestion>[];
      final optionalQs = <DiagnosisQuestion>[];
      for (final id in _qToXIds) {
        final q = _findById(id);
        if (q != null) {
          (q.isOptional ? optionalQs : requiredQs).add(q);
        }
      }
      out..addAll(requiredQs)..addAll(optionalQs);
    }
    return out;
  }

  List<DiagnosisQuestion> get _evaluationQuestions {
    final idsHistory = <String>{_chiefId, _pId, ..._qToXIds};
    final eval = diagnosisQuestions.where((q) => !idsHistory.contains(q.id)).toList();
    // Move optional to the end
    final requiredQs = eval.where((q) => !q.isOptional).toList();
    final optionalQs = eval.where((q) => q.isOptional).toList();
    return [...requiredQs, ...optionalQs];
  }

  List<DiagnosisQuestion> get _activeQuestions =>
      _onHistory ? _historyQuestions : _evaluationQuestions;

  // -------------------- Validation for Next --------------------
  bool _historyValid() {
    final p = _findById(_pId);
    if (p == null) {
      final cc = _findById(_chiefId);
      if (cc == null) return true;
      return _answers[cc.id] != null;
    }

    final pAnswer = _answers[p.id];
    if (pAnswer == null || (pAnswer is String && pAnswer.isEmpty)) {
      return false;
    }

    if (_pIsYes) {
      for (final id in _qToXIds) {
        final q = _findById(id);
        if (q != null && !q.isOptional) {
          final val = _answers[q.id];
          if (val == null || (val is String && val.isEmpty)) return false;
        }
      }
    }
    return true;
  }

  // -------------------- Step navigation with scroll-to-top --------------------
  void _goToStep(int step) {
    setState(() => _currentStep = step);
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
        _removeExistingImage = false; // user provided a new file
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
  void _clearAnswer(String id) {
    setState(() {
      _answers.remove(id);
      if (id == _chiefId) {
        _answers.remove('chief_complaint_text');
        _chiefComplaintTextController.clear();
      }
    });
  }

  void _clearAllAnswers() {
    setState(() {
      _answers.clear();
      _chiefComplaintTextController.clear();
      _selectedTooth = null;
      _toothNumberController.clear();
      _toothNumberError = null;
      _selectedImage = null;
      _webImageBytes = null;
      _removeExistingImage = false;
    });
  }

  // Ensure overrides held before any compute/submit
  void _normalizeAnswersBeforeSubmit() {
    _enforcePercussionOverrides();
  }

  // Some clinical rules require keeping answers consistent.
  // Currently only a placeholder for percussion-related overrides.
  // If specific business logic is needed, add it here.
  void _enforcePercussionOverrides() {
    // Example placeholder: if chief complaint is 'No', clear its text.
    final cc = _answers[_chiefId];
    if (cc == 'No') {
      _answers.remove('chief_complaint_text');
      _chiefComplaintTextController.clear();
    }
    // Add percussion/biting related normalization here as requirements evolve.
  }

  // -------------------- Next from Page-1 (fetch etiologies) -------------
  Future<void> _onNextFromHistory() async {
    _normalizeAnswersBeforeSubmit();
    final controllerValue = _toothNumberController.text.trim();
    if (controllerValue.isEmpty) {
      final fallback = _selectedTooth ?? '0';
      _selectedTooth ??= fallback;
      _toothNumberController.text = fallback;
    }
    if (_toothNumberError != null) {
      setState(() => _toothNumberError = null);
    }

    // If P != Yes -> wipe Q..X before moving (they were not shown)
    if (!_pIsYes) {
      for (final id in _qToXIds) {
        _answers.remove(id);
      }
    }
    _goToStep(1);
  }

  // -------------------- Submit / Save --------------------
  Future<void> _submitDiagnosis() async {
    setState(() => _submitting = true);

    try {
      _normalizeAnswersBeforeSubmit();
      if (_isEdit && _visitId != null) {
        // EDIT: save changes
        await ApiService().updateVisit(
          visitId: _visitId!,
          fields: {
            'tooth_number': _toothNumberController.text,
            'answers': _answers.map(
              (k, v) => MapEntry(k, v is List ? v : v.toString()),
            ),
          },
          toothImage: _selectedImage,
          webImageBytes: _webImageBytes,
          removeToothImage: _removeExistingImage,
        );

        if (!mounted) return;

        // -> After saving, go to Diagnosis Result for this visit
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => DiagnosisResultScreen(
                  visitId: _visitId!,
                  patientName: '${_patient.firstName} ${_patient.lastName}',
                ),
          ),
        );

        if (!mounted) return;
        // When leaving result page, return to profile and refresh list
        Navigator.pop(context, 'refresh');
        return;
      }

      // ---- CREATE FLOW (compatible with visitId) ----

      // build a clean answers map
      final Map<String, dynamic> cleanedAnswers = _answers.map(
        (k, v) => MapEntry(k, v is List ? v : (v?.toString() ?? '')),
      );

      // do NOT send read-only fields
      final dynamic created = await ApiService().createVisit(
        patientId: _patient.id,
        toothNumber: _toothNumberController.text,
        answers: cleanedAnswers,
        toothImage: _selectedImage,
        webImageBytes: _webImageBytes,
      );

      // accept both shapes: int id OR full JSON body
      final dynamic rawVisitId =
          (created is Map<String, dynamic>) ? created['id'] : created;

      if (rawVisitId == null) {
        throw Exception('Create visit returned unexpected payload');
      }

      late final int visitId;
      if (rawVisitId is int) {
        visitId = rawVisitId;
      } else if (rawVisitId is num) {
        visitId = rawVisitId.toInt();
      } else if (rawVisitId is String) {
        visitId =
            int.tryParse(rawVisitId) ??
            (throw Exception('Create visit: id is not a number'));
      } else {
        throw Exception('Create visit: unexpected id type');
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => DiagnosisResultScreen(
                visitId: visitId, // screen fetches the visit by ID
                patientName: '${_patient.firstName} ${_patient.lastName}',
              ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit: $e")));
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
                child: AppHeader(
                  title: _isEdit ? 'Edit Diagnosis' : 'New Diagnosis',
                  subtitle:
                      _isEdit
                          ? 'Update answers and attachments for this visit.'
                          : 'Record patient case step-by-step',
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

            // Page header
            SliverToBoxAdapter(
              child: _buildPageHeader(
                title:
                    _onHistory
                        ? 'Patient History'
                        : 'Clinical & Radiographic Evaluation',
                subtitle:
                    _onHistory
                        ? 'Answer a few short questions about symptoms and history.'
                        : 'Record clinical tests and radiographic findings.',
              ),
            ),

            // Patient card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PatientInfoCard(
                  patient: _patient,
                  toothNumber: _toothNumberController.text,
                ),
              ),
            ),

            // Tooth & Photo - Page 1 only
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

            // Questions for active step
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final q = _activeQuestions[index];
                final isMulti = q.id == 'etiology_assessment';
                return _buildQuestionCard(
                  q,
                  isMulti: isMulti,
                  displayIndex: index + 1,
                  totalCount: totalQuestions,
                );
              }, childCount: totalQuestions),
            ),

            // Navigation buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (!_onHistory)
                      _buildNavigationButton('Back', () => _goToStep(0)),
                    const Spacer(),
                    _onHistory
                        ? _buildNavigationButton(
                          'Next',
                          _historyValid() ? _onNextFromHistory : null,
                        )
                        : _buildNavigationButton(
                          _submitting
                              ? (_isEdit ? 'Saving...' : 'Submitting...')
                              : (_isEdit ? 'Save changes' : 'Submit'),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
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
    final selectedLabel =
        _selectedTooth == null
            ? 'Tap a tooth to select.'
            : 'Selected tooth: ${_selectedTooth!}';

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
              'Select Tooth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              selectedLabel,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Numbering system:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('FDI'),
                        selected: _numberingSystem == ToothNumberingSystem.fdi,
                        onSelected: (selected) {
                          if (selected) {
                            setState(
                              () => _numberingSystem = ToothNumberingSystem.fdi,
                            );
                          }
                        },
                        selectedColor: const Color(0xFF7E22CE),
                        labelStyle: TextStyle(
                          color:
                              _numberingSystem == ToothNumberingSystem.fdi
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('UTN'),
                        selected: _numberingSystem == ToothNumberingSystem.utn,
                        onSelected: (selected) {
                          if (selected) {
                            setState(
                              () => _numberingSystem = ToothNumberingSystem.utn,
                            );
                          }
                        },
                        selectedColor: const Color(0xFF7E22CE),
                        labelStyle: TextStyle(
                          color:
                              _numberingSystem == ToothNumberingSystem.utn
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ToothPicker(
              selectedTooth: _selectedTooth,
              onChanged: _onToothSelected,
              numberingSystem: _numberingSystem,
              // variantMode: ToothVariantMode.anatomical, // <ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â remove; not used with SVG version
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: _toothNumberError != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(
                _toothNumberError ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_outlined),
                  label: Text(
                    _isEdit ? 'Replace / Upload Photo' : 'Upload Tooth Photo',
                  ),
                ),
                const SizedBox(width: 12),
                if (_isEdit &&
                    _existingImageUrl != null &&
                    _selectedImage == null)
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Remove existing photo'),
                      value: _removeExistingImage,
                      onChanged:
                          (v) =>
                              setState(() => _removeExistingImage = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              kIsWeb
                  ? (_webImageBytes != null
                      ? Image.memory(_webImageBytes!, height: 100)
                      : const CircularProgressIndicator())
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
            Text(
              q.text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            if (isMulti)
              ...q.options.map((option) {
                final selected = (_answers[q.id] as List?) ?? const [];
                final notSureSelected = selected.contains('Not sure');

                final isEnabled = !notSureSelected || option == 'Not sure';

                return CheckboxListTile(
                  title: Text(option),
                  enabled: isEnabled,
                  value: selected.contains(option),
                  onChanged: (selectedVal) {
                    setState(() {
                      final current = List<String>.from(
                        (_answers[q.id] as List?) ?? const [],
                      );
                      if (selectedVal == true) {
                        if (option == 'Not sure') {
                          _answers[q.id] = ['Not sure'];
                        } else {
                          current.remove('Not sure');
                          if (!current.contains(option)) current.add(option);
                          _answers[q.id] = current;
                        }
                      } else {
                        current.remove(option);
                        _answers[q.id] = current;
                      }
                    });
                  },
                );
              })
            else
              ...q.options.map(
                (option) => RadioListTile(
                  title: Text(option),
                  value: option,
                  groupValue: _answers[q.id],
                  onChanged: (val) {
                    setState(() {
                      _answers[q.id] = val;
                      if (isChiefComplaint && val == 'No') {
                        _answers.remove('chief_complaint_text');
                        _chiefComplaintTextController.clear();
                      }
                      // Enforce percussion overrides biting rule
                      _enforcePercussionOverrides();
                    });
                  },
                ),
              ),

            if (isChiefComplaint && _answers[q.id] == 'Yes') ...[
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
                    _answers['chief_complaint_text'] = txt;
                  });
                },
              ),
            ],

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _clearAnswer(q.id),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: const Color(0xFFF8FAFC), elevation: 4, child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
