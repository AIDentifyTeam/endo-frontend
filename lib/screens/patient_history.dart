import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/services/api_service.dart';
import '../routes.dart';

class PatientSelectionPage extends StatefulWidget {
  const PatientSelectionPage({super.key});

  @override
  _PatientSelectionPageState createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  List<Patient> allPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final patients = await ApiService().getPatients();
    setState(() {
      allPatients = patients;
      _isLoading = false;
    });
  }

  List<Patient> get filteredPatients {
    String searchTerm = _searchController.text.toLowerCase();
    List<Patient> filtered = allPatients.where((p) {
      return p.firstName.toLowerCase().contains(searchTerm) ||
          p.lastName.toLowerCase().contains(searchTerm) ||
          p.id.toString().contains(searchTerm);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return '${a.lastName} ${a.firstName}'.compareTo('${b.lastName} ${b.firstName}');
        case 'id':
          return a.id.compareTo(b.id);
        case 'age':
          return b.age.compareTo(a.age);
        case 'lastVisit':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return 0;
      }
    });

    return filtered;
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
              title: 'Patient History',
              subtitle: 'Browse and manage all previous patient visits',
              icon: Icons.history,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name or ID',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: const [
                                DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                                DropdownMenuItem(value: 'id', child: Text('Sort by Case ID')),
                                DropdownMenuItem(value: 'age', child: Text('Sort by Age')),
                                DropdownMenuItem(value: 'lastVisit', child: Text('Sort by Created Date')),
                              ],
                              onChanged: (value) => setState(() => _sortBy = value!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Expanded(
                            child: ListView.separated(
                              itemCount: filteredPatients.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 1),
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF2563EB),
                                      child: Text(
                                        '${patient.firstName[0]}${patient.lastName[0]}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      '${patient.firstName} ${patient.lastName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Patient ID: ${patient.patientId}  •  Age: ${patient.age}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Created At',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          patient.createdAt.split('T').first,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        Routes.patientProfile,
                                        arguments: patient,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/new_patient'),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'New Patient',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
