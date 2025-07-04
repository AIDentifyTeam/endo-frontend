import 'package:flutter/material.dart';

class PatientSelectionPage extends StatefulWidget {
  const PatientSelectionPage({super.key});

  @override
  _PatientSelectionPageState createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  bool _showNewPatientDialog = false;
  
  // Form controllers for new patient
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSex;

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
    {
      'id': 'P003',
      'firstName': 'Emma',
      'lastName': 'Davis',
      'age': 45,
      'phone': '(555) 345-6789',
      'email': 'emma.d@email.com',
      'lastVisit': '2025-05-28'
    },
    {
      'id': 'P004',
      'firstName': 'James',
      'lastName': 'Wilson',
      'age': 52,
      'phone': '(555) 456-7890',
      'email': 'james.w@email.com',
      'lastVisit': '2025-05-25'
    },
    {
      'id': 'P005',
      'firstName': 'Lisa',
      'lastName': 'Anderson',
      'age': 31,
      'phone': '(555) 567-8901',
      'email': 'lisa.a@email.com',
      'lastVisit': '2025-05-22'
    },
    {
      'id': 'P006',
      'firstName': 'David',
      'lastName': 'Brown',
      'age': 39,
      'phone': '(555) 678-9012',
      'email': 'david.b@email.com',
      'lastVisit': '2025-05-20'
    },
    {
      'id': 'P007',
      'firstName': 'Maria',
      'lastName': 'Garcia',
      'age': 26,
      'phone': '(555) 789-0123',
      'email': 'maria.g@email.com',
      'lastVisit': '2025-05-18'
    },
    {
      'id': 'P008',
      'firstName': 'Robert',
      'lastName': 'Miller',
      'age': 48,
      'phone': '(555) 890-1234',
      'email': 'robert.m@email.com',
      'lastVisit': '2025-05-15'
    },
    {
      'id': 'P009',
      'firstName': 'Jennifer',
      'lastName': 'Taylor',
      'age': 35,
      'phone': '(555) 901-2345',
      'email': 'jennifer.t@email.com',
      'lastVisit': '2025-05-12'
    },
    {
      'id': 'P010',
      'firstName': 'Christopher',
      'lastName': 'Lee',
      'age': 41,
      'phone': '(555) 012-3456',
      'email': 'chris.l@email.com',
      'lastVisit': '2025-05-10'
    },
  ];

  List<Map<String, dynamic>> get filteredPatients {
    List<Map<String, dynamic>> filtered = allPatients.where((patient) {
      String searchTerm = _searchController.text.toLowerCase();
      return patient['firstName'].toLowerCase().contains(searchTerm) ||
             patient['lastName'].toLowerCase().contains(searchTerm) ||
             patient['id'].toLowerCase().contains(searchTerm);
    }).toList();

    // Sort patients
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
            colors: [
              Color(0xFFEBF4FF),
              Color(0xFFFFF1F1)

              ],
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
                    setState(() {
                      _showNewPatientDialog = true;
                    });
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
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                    DropdownMenuItem(
                      value: 'id',
                      child: Text('Sort by ID'),
                    ),
                    DropdownMenuItem(
                      value: 'age',
                      child: Text('Sort by Age'),
                    ),
                    DropdownMenuItem(
                      value: 'lastVisit',
                      child: Text('Sort by Last Visit'),
                    ),
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
                // New Patient Dialog
                if (_showNewPatientDialog)
                  _buildNewPatientDialog(context),
                ],
              ),
              ),
            ),
            ),
          );
          }

          Widget _buildNewPatientDialog(BuildContext context) {
          return Stack(
            children: [
            // Semi-transparent background
            Positioned.fill(
              child: GestureDetector(
              onTap: () {
                setState(() {
                _showNewPatientDialog = false;
                });
              },
              child: Container(
                color: Colors.black54,
              ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                    ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12),
                    Row(
                    children: [
                      Expanded(
                      child: InkWell(
                        onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                          _selectedDate = picked;
                          });
                        }
                        },
                        child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate == null
                            ? 'Select'
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                        ),
                        ),
                      ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSex,
                        items: [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text('Male'),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                        ],
                        onChanged: (value) {
                        setState(() {
                          _selectedSex = value;
                        });
                        },
                        decoration: InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                        ),
                      ),
                      ),
                    ],
                    ),
                    SizedBox(height: 24),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                      onPressed: () {
                        setState(() {
                        _showNewPatientDialog = false;
                        });
                      },
                      child: Text('Cancel'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                      onPressed: () {
                        // Add new patient logic
                        if (_firstNameController.text.isNotEmpty &&
                          _lastNameController.text.isNotEmpty &&
                          _idController.text.isNotEmpty) {
                        setState(() {
                          allPatients.add({
                          'id': _idController.text,
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'age': _selectedDate == null
                            ? null
                            : DateTime.now().year - _selectedDate!.year,
                          'phone': _phoneController.text,
                          'email': _emailController.text,
                          'lastVisit': DateTime.now().toIso8601String().substring(0, 10),
                          });
                          _firstNameController.clear();
                          _lastNameController.clear();
                          _idController.clear();
                          _phoneController.clear();
                          _emailController.clear();
                          _selectedDate = null;
                          _selectedSex = null;
                          _showNewPatientDialog = false;
                        });
                        }
                      },
                      child: Text('Add Patient'),
                      ),
                    ],
                    ),
                  ],
                  ),
                ),
                ),
              ),
              ),
            ),
            ],
          );
          }
        }