import 'package:endo_frontend/widgets/patient_info_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/diagnosis_result.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/services/api_service.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  List<Map<String, dynamic>> visitHistory = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.patient.firstName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    fetchVisitHistory();
  }

  Future<void> fetchVisitHistory() async {
    final visits = await ApiService().fetchVisitHistory(widget.patient.id);

    visits.sort((a, b) {
      final dateA = DateTime.tryParse(a['visit_date'] ?? '') ?? DateTime(1900);
      final dateB = DateTime.tryParse(b['visit_date'] ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA); // newest first
    });

    setState(() {
      visitHistory = visits;
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
              title: 'Patient Profile',
              subtitle: 'Details and Visit History',
              icon: Icons.person,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientInfoCard(patient: widget.patient),
                    const SizedBox(height: 24),
                    const Text(
                      'Visit History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildVisitList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/new_diagnosis',
            arguments: widget.patient,
          );
          if (result == 'refresh') {
            fetchVisitHistory();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Diagnosis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildVisitList() {
    if (visitHistory.isEmpty) {
      return const Center(
        child: Text(
          'No visit history exists.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: visitHistory.length,
      itemBuilder: (context, index) {
        final visit = visitHistory[index];
        final visitDate = DateTime.parse(visit['visit_date']).toLocal();
        final formattedDate =
            DateFormat('yyyy-MM-dd – h:mm a').format(visitDate);

        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEFF6FF), // light indigo
              child: Text(
                (visit['tooth_number'] ?? '-').toString(),
                style: const TextStyle(
                  color: Color(0xFF1E3A8A), // indigo-900
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              'Case ID: ${visit['case_id'] ?? '-'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '•  Date: $formattedDate   \n•  Tooth: ${visit['tooth_number']}  •  Diagnosis: ${visit['pulp_diagnosis'] ?? 'N/A'} ',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),

            // --- Three professional actions: View | Edit | Delete
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // VIEW
                IconButton(
                  tooltip: 'View',
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 22,
                    color: Color(0xFF475569), // slate-700
                  ),
                  onPressed: () async {
                    final shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiagnosisResultScreen(
                          visitId: visit['id'],
                          patientName:
                              '${_firstNameController.text} ${_lastNameController.text}',
                        ),
                      ),
                    );
                    if (shouldRefresh == true) {
                      await fetchVisitHistory();
                    }
                  },
                ),
                const SizedBox(width: 4),

                // EDIT → go to new_diagnosis form in edit mode
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 22,
                    color: Color(0xFF2563EB), // indigo-600
                  ),
                  onPressed: () async {
                    // Pass everything the form needs to prefill.
                    // Your NewDiagnosisScreen should detect "mode: edit" + "visitId"
                    // and preload via fetchVisitById(visitId) if necessary.
                    final result = await Navigator.pushNamed(
                      context,
                      '/new_diagnosis',
                      arguments: {
                        'mode': 'edit',
                        'patient': widget.patient,
                        'visitId': visit['id'],
                      },
                    );
                    if (result == 'refresh' || result == true) {
                      await fetchVisitHistory();
                    }
                  },
                ),
                const SizedBox(width: 4),

                // DELETE
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: Color(0xFFDC2626), // red-600
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Visit'),
                        content: const Text(
                          'Are you sure you want to delete this visit? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ApiService().deleteVisit(visit['id']);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Visit deleted successfully')),
                          );
                        }
                        await fetchVisitHistory();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to delete visit: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),

            // Keep row tap as VIEW for convenience
            onTap: () async {
              final shouldRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosisResultScreen(
                    visitId: visit['id'],
                    patientName:
                        '${_firstNameController.text} ${_lastNameController.text}',
                  ),
                ),
              );
              if (shouldRefresh == true) {
                await fetchVisitHistory();
              }
            },
          ),
        );
      },
    );
  }
}
