import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/services/api_service.dart';
import 'package:endo_frontend/data/diagnosis_questions.dart'; // <-- use titles from here

class DiagnosisResultScreen extends StatefulWidget {
  final int visitId;
  final String patientName;

  const DiagnosisResultScreen({
    super.key,
    required this.visitId,
    required this.patientName,
  });

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  Map<String, dynamic>? visitData;
  bool isLoading = true;

  /// Build a label map: question id -> human readable title
  late final Map<String, String> _labelById = {
    for (final q in diagnosisQuestions) q.id: q.title,
    // extra (non-question) fields we show in answers:
    'etiology_assessment': 'Etiology Assessment',
    'endo_history': 'Endodontic Treatment History',
    'chief_complaint': 'Chief Complaint',
    'chief_complaint_text': 'Chief Complaint (notes)',
    'radiographic_findings': 'Radiographic Findings',
  };

  /// For ordering on the summary page: same order as the questionnaire
  late final List<String> _answerOrder = [
    // History page
    'chief_complaint',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    // Evaluation page
    'etiology_assessment',
    'endo_history',
    'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'radiographic_findings',
  ];

  @override
  void initState() {
    super.initState();
    fetchVisitData();
  }

  Future<void> fetchVisitData() async {
    try {
      final data = await ApiService().fetchVisitById(widget.visitId);
      setState(() {
        visitData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load visit data')),
      );
    }
  }

  String _labelFor(String key) => _labelById[key] ?? key;

  String _stringifyValue(dynamic v) {
    if (v == null) return '-';
    if (v is List) return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).join(', ');
    return v.toString();
  }

  List<MapEntry<String, dynamic>> _orderedAnswers(Map<String, dynamic> answers) {
    final keys = answers.keys.toSet();
    final ordered = <MapEntry<String, dynamic>>[];

    // add in defined order
    for (final k in _answerOrder) {
      if (keys.remove(k)) {
        ordered.add(MapEntry(k, answers[k]));
      }
    }
    // append any remaining keys (unexpected/new)
    for (final k in keys) {
      ordered.add(MapEntry(k, answers[k]));
    }
    return ordered;
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
              title: 'Diagnosis Summary',
              subtitle: 'Overview of diagnosis results',
              icon: Icons.assignment_turned_in,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : visitData == null
                      ? const Center(child: Text('No visit data available.'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionCard(
                                title: 'Visit Details',
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow('Visit Date:', visitData!['visit_date'] ?? '-'),
                                    _infoRow('Patient:', widget.patientName),
                                    _infoRow('Tooth Number:', visitData!['tooth_number'] ?? '-'),
                                  ],
                                ),
                              ),
                              if (visitData!['tooth_image'] != null &&
                                  visitData!['tooth_image'].toString().isNotEmpty)
                                _buildSectionCard(
                                  title: 'Tooth Image',
                                  content: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      '${visitData!['tooth_image']}',
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Text('⚠️ Failed to load image'),
                                    ),
                                  ),
                                ),
                              _buildSectionCard(
                                title: 'Diagnosis Answers',
                                content: _buildAnswersList(),
                              ),
                              _buildSectionCard(
                                title: 'Diagnosis Result',
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildDiagnosisCards(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context, 'refresh');
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back to Visit History List'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
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

  /// Render the key→value answers with pretty labels and ordering.
  Widget _buildAnswersList() {
    final Map<String, dynamic> answers =
        (visitData!['answers'] as Map<String, dynamic>?) ?? const {};
    final ordered = _orderedAnswers(answers);

    if (ordered.isEmpty) return const Text('No answers recorded.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ordered
          .map((e) => _infoRow(_labelFor(e.key), _stringifyValue(e.value)))
          .toList(),
    );
  }

  List<Widget> _buildDiagnosisCards() {
    final List results = visitData!['results'] ?? [];
    if (results.isEmpty) {
      return [const Text('No diagnosis results available.')];
    }

    return results.map((res) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🦷 Pulp Diagnosis: ${res['pulp_diagnosis'] ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('🦠 Periapical Disease: ${res['periapical_disease'] ?? 'N/A'}'),
            const SizedBox(height: 6),
            Text('🎯 Etiology: ${res['etiology'] ?? 'N/A'}'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                )),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 4,
            child: Text('$label ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
