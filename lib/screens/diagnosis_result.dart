import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/services/api_service.dart';
import 'package:endo_frontend/data/diagnosis_questions.dart'; // <-- titles from here

class DiagnosisResultScreen extends StatefulWidget {
  final int visitId;
  final String patientName;
  final bool isEditing;

  const DiagnosisResultScreen({
    super.key,
    required this.visitId,
    required this.patientName,
    this.isEditing = false,
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
    // extras we show in answers:
    'etiology_assessment': 'Etiology Assessment',
    'endo_history': 'Endodontic Treatment History',
    'chief_complaint': 'Chief Complaint',
    'chief_complaint_text': 'Chief Complaint (notes)',
    'N': 'Radiographic Findings', // backend uses N in answers
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
    'N', // radiographic
  ];

  @override
  void initState() {
    super.initState();
    fetchVisitData();
  }

  Future<void> fetchVisitData() async {
    try {
      final data = await ApiService().fetchVisitById(widget.visitId);
      if (!mounted) return;
      setState(() {
        visitData = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .join(', ');
    }
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
        (visitData!['answers'] as Map<String, dynamic>? ?? const {});
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
    final resultsObj = visitData!['results'] as Map<String, dynamic>?;
    if (resultsObj == null || resultsObj.isEmpty) {
      return [const Text('No diagnosis results available.')];
    }

    final source = (resultsObj['source'] ?? '').toString();
    final engineVer = (resultsObj['engine_version'] ?? '').toString();

    // RULES ENGINE
    if (source == 'rules_engine') {
      final list = (resultsObj['results'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (list.isEmpty) {
        return [
          _badgeRow(source: 'Rule-based', engineVer: engineVer),
          const SizedBox(height: 8),
          const Text('No deterministic match found.'),
        ];
      }

      return [
        _badgeRow(source: 'Rule-based', engineVer: engineVer),
        const SizedBox(height: 12),
        ...list.map((res) {
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
                Text(
                  res['pulp_diagnosis'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('Periapical: ${res['periapical_disease'] ?? 'N/A'}'),
                const SizedBox(height: 6),
                Text('Etiology: ${res['etiology'] ?? 'N/A'}'),
              ],
            ),
          );
        }),
      ];
    }

    // AI FALLBACK
    if (source == 'ai_fallback_gemini') {
      final aiText = (resultsObj['ai_text'] ?? resultsObj['ai'] ?? '').toString();
      return [
        _badgeRow(source: 'AI-assisted', engineVer: engineVer, icon: Icons.smart_toy_outlined),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              Text(
                aiText.isEmpty ? 'No AI suggestion available.' : aiText,
                style: const TextStyle(fontFamily: 'monospace', height: 1.3),
                softWrap: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Not a diagnosis. For clinical guidance only.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ];
    }

    // NONE / unknown
    return [
      _badgeRow(source: 'No result', engineVer: engineVer),
      const SizedBox(height: 8),
      const Text('No results available.'),
    ];
  }

  Widget _badgeRow({required String source, required String engineVer, IconData icon = Icons.fact_check_outlined}) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          source,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo),
        ),
        const Spacer(),
        Text('v$engineVer', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
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
