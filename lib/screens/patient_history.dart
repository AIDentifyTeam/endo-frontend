import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/models/patient.dart';
import '../routes.dart';

class PatientSelectionPage extends StatefulWidget {
  const PatientSelectionPage({super.key});

  @override
  _PatientSelectionPageState createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';

  final List<Map<String, dynamic>> allPatients = [
    {
      'id': 'P001',
      'firstName': 'Sarah',
      'lastName': 'Johnson',
      'age': 34,
      'phone': '(555) 123-4567',
      'email': 'sarah.j@email.com',
      'lastVisit': '2025-06-01'
    },
    {
      'id': 'P002',
      'firstName': 'Michael',
      'lastName': 'Chen',
      'age': 28,
      'phone': '(555) 234-5678',
      'email': 'michael.c@email.com',
      'lastVisit': '2025-05-30'
    },
  ];

  List<Map<String, dynamic>> get filteredPatients {
    List<Map<String, dynamic>> filtered = allPatients.where((patient) {
      String searchTerm = _searchController.text.toLowerCase();
      return patient['firstName'].toLowerCase().contains(searchTerm) ||
          patient['lastName'].toLowerCase().contains(searchTerm) ||
          patient['id'].toLowerCase().contains(searchTerm);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return '${a['lastName']} ${a['firstName']}'
              .compareTo('${b['lastName']} ${b['firstName']}');
        case 'id':
          return a['id'].compareTo(b['id']);
        case 'age':
          return a['age'].compareTo(b['age']);
        case 'lastVisit':
          return DateTime.parse(b['lastVisit'])
              .compareTo(DateTime.parse(a['lastVisit']));
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
            AppHeader(
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
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.white,
                          ),
                          child: Container(
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
                                  DropdownMenuItem(value: 'id', child: Text('Sort by ID')),
                                  DropdownMenuItem(value: 'age', child: Text('Sort by Age')),
                                  DropdownMenuItem(value: 'lastVisit', child: Text('Sort by Last Visit')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortBy = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
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
                                  patient['firstName'][0] + patient['lastName'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '${patient['firstName']} ${patient['lastName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${patient['id']}  •  Age: ${patient['age']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Last Visit',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    patient['lastVisit'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final selectedPatient = Patient(
                                  id: patient['id'],
                                  firstName: patient['firstName'],
                                  lastName: patient['lastName'],
                                  age: patient['age'],
                                  phone: patient['phone'],
                                  email: patient['email'],
                                  lastVisit: patient['lastVisit'],
                                );

                                Navigator.of(context).pushNamed(
                                  Routes.patientProfile,
                                  arguments: selectedPatient,
                                );
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
        onPressed: () {
          Navigator.of(context).pushNamed('/new_patient');
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'New Patient',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
