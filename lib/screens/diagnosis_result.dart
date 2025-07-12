import 'dart:io';
import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final String patientName;
  final String visitDate;
  final String toothNumber;
  final File? toothImage;
  final Map<String, String> answers;

  const DiagnosisResultScreen({
    super.key,
    required this.patientName,
    required this.visitDate,
    required this.toothNumber,
    this.toothImage,
    required this.answers,
  });

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: 'Visit Details',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Visit Date:', visitDate),
                          _infoRow('Patient:', patientName),
                          _infoRow('Tooth Number:', toothNumber),
                        ],
                      ),
                    ),
                    if (toothImage != null)
                      _buildSectionCard(
                        title: 'Tooth Image',
                        content: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(toothImage!, height: 180),
                        ),
                      ),
                    _buildSectionCard(
                      title: 'Diagnosis Answers',
                      content: Column(
                        children: answers.entries.map((entry) {
                          return _infoRow(entry.key, entry.value);
                        }).toList(),
                      ),
                    ),
                    _buildSectionCard(
                      title: 'Diagnosis Result',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('🦷 Pulp Diagnosis: Irreversible Pulpitis'),
                          SizedBox(height: 8),
                          Text('🦠 Periapical Disease: Symptomatic Apical Periodontitis'),
                          SizedBox(height: 8),
                          Text('🎯 Etiology: Deep Caries'),
                        ],
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
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
