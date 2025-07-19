import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/models/visit.dart';
import 'package:endo_frontend/screens/patient_profile.dart';
import 'package:endo_frontend/services/api_service.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  List<Patient> patients = [];
  List<Visit> visits = [];
  List<Patient> recentPatients = [];
  List<Visit> todayVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final patientsRaw = await ApiService().getPatients();
    final visitsRaw = await ApiService().getVisits();
    final today = DateTime.now().toIso8601String().split('T').first;

    final patients = (patientsRaw ?? []).cast<Patient>();
    final visits = (visitsRaw ?? []).map((v) => Visit.fromJson(v)).toList();

    final todayVisitsList = visits
        .where((v) =>
            v.visitDate != null &&
            v.visitDate.toString().startsWith(today))
        .toList();

    setState(() {
      this.patients = patients;
      this.visits = visits;
      recentPatients = patients.take(5).toList();
      todayVisits = todayVisitsList;
      isLoading = false;
    });
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
              title: 'Dashboard',
              subtitle: 'Overview of your endodontic activity',
              icon: Icons.dashboard,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 600;
                              return isWide
                                  ? Row(
                                      children: [
                                        Expanded(child: _buildQuickActionCard(
                                          icon: Icons.add,
                                          title: 'New Patient',
                                          description: 'Create a new patient record and start diagnosis',
                                          color: Colors.green,
                                          onTap: () => Navigator.pushNamed(context, '/new_patient'),
                                        )),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildQuickActionCard(
                                          icon: Icons.history,
                                          title: 'Patient History',
                                          description: 'View existing patient records',
                                          color: Colors.blue,
                                          onTap: () => Navigator.pushNamed(context, '/patient_history'),
                                        )),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildQuickActionCard(
                                          icon: Icons.add,
                                          title: 'New Patient',
                                          description: 'Create a new patient record and start diagnosis',
                                          color: Colors.green,
                                          onTap: () => Navigator.pushNamed(context, '/new_patient'),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildQuickActionCard(
                                          icon: Icons.history,
                                          title: 'Patient History',
                                          description: 'View existing patient records',
                                          color: Colors.blue,
                                          onTap: () => Navigator.pushNamed(context, '/patient_history'),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildRecentPatientsCard(),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 600;
                              return isWide
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _buildTodaySummaryCard()),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildLatestResearchCard()),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTodaySummaryCard(),
                                        const SizedBox(height: 16),
                                        _buildLatestResearchCard(),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatientsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Patients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentPatients.isEmpty)
            const Center(
              child: Text('No recent patients found.', style: TextStyle(color: Colors.grey)),
            )
          else
            Column(
              children: recentPatients.map((patient) {
                final birthDate = DateTime.tryParse(patient.birthDate);
                final now = DateTime.now();
                final age = birthDate != null
                    ? now.year - birthDate.year - ((now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) ? 1 : 0)
                    : '?';

                return Card(
                  color: const Color(0xFFF9FAFB),
                  elevation: 1,
                  margin: const EdgeInsets.only(top: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2563EB),
                      child: Text(
                        patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${patient.firstName} ${patient.lastName}'),
                    subtitle: Text('Patient ID: ${patient.patientId} | Age: $age'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientProfileScreen(patient: patient),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    int diagnosesMade = todayVisits.length;
    int rctRecommended = todayVisits.where((v) => v.etiology.toLowerCase().contains('caries')).length;

    return Container(
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 190, 190, 8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text("Today's Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Patients Seen', todayVisits.length.toString(), Colors.blue),
          _buildSummaryRow('Diagnoses Made', diagnosesMade.toString(), Colors.green),
          _buildSummaryRow('RCT Recommended', rctRecommended.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLatestResearchCard() {
    final researchPapers = [
      {'title': 'Novel Approaches to Vital Pulp Therapy', 'rating': 4.8},
      {'title': 'AI in Endodontic Diagnosis', 'rating': 4.9},
      {'title': 'Regenerative Endodontics Update', 'rating': 4.7},
    ];

    return Container(
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text('Latest Research',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...researchPapers.map((paper) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(paper['title'] as String)),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(paper['rating'].toString()),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
