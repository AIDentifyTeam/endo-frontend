import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:flutter/material.dart';

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
              searchController: _searchController,
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
                            canvasColor: Colors.white, // dropdown background
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
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          itemCount: filteredPatients.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  patient['firstName'][0] + patient['lastName'][0],
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text('${patient['firstName']} ${patient['lastName']}'),
                              subtitle: Text('ID: ${patient['id']} | Age: ${patient['age']}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Last Visit',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    patient['lastVisit'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // TODO: Navigate to patient profile or visit details
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('New Patient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/new_patient');
                        },
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
}
