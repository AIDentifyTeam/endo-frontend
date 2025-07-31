import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/services/api_service.dart';

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
                                    _infoRow('Visit Date:', visitData!['visit_date']),
                                    _infoRow('Patient:', widget.patientName),
                                    _infoRow('Tooth Number:', visitData!['tooth_number']),
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
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (visitData!['answers'] as Map<String, dynamic>)
                                      .entries
                                      .map((entry) => _infoRow(entry.key, entry.value.toString()))
                                      .toList(),
                                ),
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
        boxShadow: [
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
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
