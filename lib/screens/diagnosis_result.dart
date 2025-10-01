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

  List<MapEntry<String, dynamic>> _orderedAnswers(
    Map<String, dynamic> answers,
  ) {
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
              child:
                  isLoading
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
                                  _infoRow(
                                    'Visit Date:',
                                    visitData!['visit_date'] ?? '-',
                                  ),
                                  _infoRow('Patient:', widget.patientName),
                                  _infoRow(
                                    'Tooth Number:',
                                    visitData!['tooth_number'] ?? '-',
                                  ),
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Text(
                                              'âš ï¸ Failed to load image',
                                            ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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

  /// Render the keyâ†’value answers with pretty labels and ordering.
  Widget _buildAnswersList() {
    final Map<String, dynamic> answers =
        (visitData!['answers'] as Map<String, dynamic>? ?? const {});
    final ordered = _orderedAnswers(answers);

    if (ordered.isEmpty) return const Text('No answers recorded.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          ordered
              .map((e) => _infoRow(_labelFor(e.key), _stringifyValue(e.value)))
              .toList(),
    );
  }

  List<Widget> _buildDiagnosisCards() {
    final resultsObj = visitData!['results'] as Map<String, dynamic>?;
    if (resultsObj == null || resultsObj.isEmpty) {
      return [const Text('No diagnosis results available.')];
    }

    final sourceKey =
        (resultsObj['source'] ?? resultsObj['result_source'] ?? '').toString();
    final engineVer = (resultsObj['engine_version'] ?? '').toString();

    final widgets = <Widget>[
      _badgeRow(
        source: _sourceLabel(
          sourceKey,
          fallback: (resultsObj['result_source'] ?? '').toString(),
        ),
        engineVer: engineVer,
        icon: _sourceIcon(sourceKey),
      ),
      const SizedBox(height: 12),
    ];

    final resultList =
        (resultsObj['results'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();

    if (resultList.isEmpty) {
      widgets.add(_noResultsCard(sourceKey));
    } else {
      widgets.addAll(resultList.map(_buildResultSummaryCard));
    }

    final aiAssist = resultsObj['ai_assist'];
    final rawAi = resultsObj['ai'];
    if (aiAssist is Map<String, dynamic> && aiAssist.isNotEmpty) {
      widgets
        ..add(const SizedBox(height: 16))
        ..add(_aiAssistPanel(aiAssist, rawText: rawAi?.toString()));
    } else if (rawAi != null && rawAi.toString().trim().isNotEmpty) {
      widgets
        ..add(const SizedBox(height: 16))
        ..add(
          _aiAssistPanel({
            'type': 'info',
            'summary': 'AI analysis',
            'messages': [
              {'type': 'info', 'text': rawAi.toString()},
            ],
          }),
        );
    }

    return widgets;
  }

  Widget _buildResultSummaryCard(Map<String, dynamic> res) {
    final pulpDiagnosis = (res['pulp_diagnosis'] ?? 'N/A').toString().trim();
    final periapicalDisease =
        (res['periapical_disease'] ?? 'N/A').toString().trim();
    final etiologies = _etiologyChipLabels(res);
    final theme = Theme.of(context);
    final chipColor = theme.colorScheme.primary;
    final chipBackground = chipColor.withOpacity(0.12);
    final chipBorder = chipColor.withOpacity(0.26);
    final chipTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: chipColor,
    );
    final etiologyTitleStyle =
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: chipColor,
        ) ??
        const TextStyle(fontWeight: FontWeight.w600);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.biotech_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pulpDiagnosis.isEmpty ? 'N/A' : pulpDiagnosis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  periapicalDisease.isEmpty
                      ? 'Periapical disease: N/A'
                      : 'Periapical disease: $periapicalDisease',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (etiologies.isEmpty)
            const Text(
              'No etiologies provided.',
              style: TextStyle(fontWeight: FontWeight.w600),
            )
          else ...[
            Row(
              children: [
                const Icon(Icons.category_outlined, color: Colors.indigo),
                const SizedBox(width: 8),
                Text('Etiologies', style: etiologyTitleStyle),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  etiologies
                      .map(
                        (label) => Chip(
                          backgroundColor: chipBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: chipBorder),
                          ),
                          label: Text(
                            label,
                            style:
                                chipTextStyle ??
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noResultsCard(String sourceKey) {
    final style = _severityStyle('info');
    final message =
        sourceKey == 'ai_fallback_gemini'
            ? 'AI fallback did not produce a structured diagnosis.'
            : 'No automated diagnosis options were returned.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: style.color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiAssistPanel(Map<String, dynamic> assist, {String? rawText}) {
    final type = (assist['type'] ?? 'info').toString().toLowerCase();
    final style = _severityStyle(type);
    final summary = (assist['summary'] ?? 'AI assist').toString();
    final messages =
        (assist['messages'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    final contextData = assist['context'];
    final formattedRaw =
        rawText != null && rawText.trim().isNotEmpty
            ? _formatAiText(rawText)
            : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(style.icon, color: style.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.isEmpty ? 'AI assist' : summary,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: style.color,
                  ),
                ),
              ),
            ],
          ),
          if (messages.isNotEmpty || formattedRaw != null)
            const SizedBox(height: 12),
          ...messages.map(_assistMessageRow),
          if (formattedRaw != null) ...[
            if (messages.isNotEmpty) const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formattedRaw,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (contextData is Map<String, dynamic> &&
              contextData.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  contextData.entries
                      .map((entry) {
                        final value = entry.value?.toString().trim();
                        if (value == null || value.isEmpty) return null;
                        return Chip(
                          avatar: const Icon(Icons.info_outline, size: 16),
                          label: Text('${entry.key}: $value'),
                        );
                      })
                      .whereType<Widget>()
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _assistMessageRow(Map<String, dynamic> message) {
    final type = (message['type'] ?? 'info').toString().toLowerCase();
    final style = _severityStyle(type);
    final text = (message['text'] ?? '').toString();
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.color, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: style.color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAiText(String raw) {
    return raw
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((line) {
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('++ ')) {
            return '  ◦ ${trimmed.substring(3)}';
          }
          if (trimmed.startsWith('+ ')) {
            return '• ${trimmed.substring(2)}';
          }
          return trimmed;
        })
        .join('\n');
  }

  String _sourceLabel(String source, {String? fallback}) {
    final key = source.isEmpty ? (fallback ?? '') : source;
    switch (key) {
      case 'rules_engine':
        return 'Aidentify Engine';
      case 'rule_override':
        return 'Heuristic Override';
      case 'ai_fallback_gemini':
        return 'AI Fallback Analysis';
      case 'none':
        return 'Automated Assist';
      default:
        return key.isEmpty ? 'Automated Assist' : key;
    }
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'rules_engine':
        return Icons.biotech_outlined;
      case 'rule_override':
        return Icons.auto_fix_high_outlined;
      case 'ai_fallback_gemini':
        return Icons.psychology_outlined;
      case 'none':
        return Icons.help_outline;
      default:
        return Icons.fact_check_outlined;
    }
  }

  _SeverityStyle _severityStyle(String type) {
    final lower = type.toLowerCase();
    late Color base;
    late IconData icon;
    switch (lower) {
      case 'success':
        base = Colors.teal;
        icon = Icons.check_circle_outline;
        break;
      case 'warning':
        base = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case 'danger':
        base = Colors.redAccent;
        icon = Icons.dangerous_outlined;
        break;
      case 'info':
        base = Colors.indigo;
        icon = Icons.info_outline;
        break;
      default:
        base = Colors.indigo;
        icon = Icons.info_outline;
        break;
    }
    return _SeverityStyle(
      color: base,
      background: base.withOpacity(0.08),
      border: base.withOpacity(0.35),
      icon: icon,
    );
  }

  List<String> _etiologyChipLabels(Map<String, dynamic> result) {
    final raw = result['etiology_list'];
    if (raw is List) {
      final merged = _mergeEtiologySegments(raw);
      if (merged.isNotEmpty) {
        return merged;
      }
    }

    final fallback = (result['etiology'] ?? '').toString().trim();
    if (fallback.isEmpty) {
      return const [];
    }

    final normalized = fallback.replaceFirst(
      RegExp(r'^Possible etiologies:?\s*', caseSensitive: false),
      '',
    );
    return [normalized.isEmpty ? fallback : normalized];
  }

  List<String> _mergeEtiologySegments(List<dynamic> raw) {
    final labels = <String>[];
    String? current;
    var balance = 0;

    for (final item in raw) {
      final part = item?.toString().trim();
      if (part == null || part.isEmpty) {
        continue;
      }

      if (current == null) {
        current = part;
        balance = _parenDelta(part);
      } else {
        current = '$current, $part';
        balance += _parenDelta(part);
      }

      if (balance <= 0) {
        labels.add(current);
        current = null;
        balance = 0;
      }
    }

    if (current != null && current.isNotEmpty) {
      labels.add(current);
    }

    return labels;
  }

  int _parenDelta(String text) {
    var delta = 0;
    for (final code in text.codeUnits) {
      if (code == 40) {
        delta++;
      } else if (code == 41) {
        delta--;
      }
    }
    return delta;
  }

  Widget _badgeRow({
    required String source,
    required String engineVer,
    IconData icon = Icons.fact_check_outlined,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          source,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
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
            child: Text(
              '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 7, child: Text(value)),
        ],
      ),
    );
  }
}

class _SeverityStyle {
  final Color color;
  final Color background;
  final Color border;
  final IconData icon;

  const _SeverityStyle({
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
  });
}
