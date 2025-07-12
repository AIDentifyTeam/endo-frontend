import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class ResearchPaper {
  final String title;
  final String authors;
  final int year;
  final String abstract;
  final String journal;
  final DateTime date;

  ResearchPaper({
    required this.title,
    required this.authors,
    required this.year,
    required this.abstract,
    required this.journal,
    required this.date,
  });
}

class ResearchPapersScreen extends StatelessWidget {
  const ResearchPapersScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final List<ResearchPaper> papers = [
      ResearchPaper(
        title: 'Regenerative Endodontic Therapy: A Review',
        authors: 'S. Patel, M. Shahravan',
        year: 2024,
        abstract:
            'This article reviews the current status of regenerative endodontics and the clinical challenges associated with it.',
        journal: 'International Endodontic Journal',
        date: DateTime(2024, 6, 15),
      ),
      ResearchPaper(
        title: 'Long-term Outcomes of Root Canal Treatment',
        authors: 'A. Lee, J. Smith',
        year: 2023,
        abstract:
            'This study investigates the success rate and complications associated with root canal therapy over a 5-year period.',
        journal: 'Journal of Endodontics',
        date: DateTime(2023, 12, 10),
      ),
      ResearchPaper(
        title: 'Cone Beam CT in Endodontics',
        authors: 'L. Torres, F. Chang',
        year: 2022,
        abstract:
            'A clinical analysis of how CBCT improves diagnostic accuracy and treatment planning in endodontics.',
        journal: 'International Endodontic Journal',
        date: DateTime(2022, 9, 21),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Research Papers',
              subtitle: 'Latest publications from IEJ and JOE',
              icon: Icons.article,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: papers.length,
                itemBuilder: (ctx, index) {
                  final p = papers[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Authors: ${p.authors}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            'Published in: ${p.journal} (${p.year})',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            p.abstract,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat('yyyy-MM-dd – HH:mm').format(p.date),
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
