import 'package:flutter/material.dart';

class PatientSelectionPage extends StatefulWidget {
  const PatientSelectionPage({super.key});

  @override
  _PatientSelectionPageState createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';

  // Sample patient data
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
    // ... (rest of your mock data)
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
          return '${a['lastName']} ${a['firstName']}'.compareTo('${b['lastName']} ${b['firstName']}');
        case 'id':
          return a['id'].compareTo(b['id']);
        case 'age':
          return a['age'].compareTo(b['age']);
        case 'lastVisit':
          return DateTime.parse(b['lastVisit']).compareTo(DateTime.parse(a['lastVisit']));
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF4FF), Color(0xFFFFF1F1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Patient Selection',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.person_add),
                      label: Text('New Patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/new_patient');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Search and Sort
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID',
                          prefixIcon: Icon(Icons.search),
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
                    SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: [
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
                  ],
                ),
                SizedBox(height: 24),
                // Patient List
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      itemCount: filteredPatients.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
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
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Handle patient selection
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
