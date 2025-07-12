import 'package:flutter/material.dart';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool isEditing = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late int age;

  final List<Map<String, dynamic>> visits = const [
    {'tooth': '12', 'date': '2025-06-30', 'diagnosis': 'Pulpitis'},
    {'tooth': '26', 'date': '2025-05-15', 'diagnosis': 'Necrotic Pulp'},
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.patient.firstName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _emailController = TextEditingController(text: widget.patient.email);
    age = widget.patient.age;
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
                    _buildPatientCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Visit History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/new_diagnosis',
            arguments: widget.patient,
          );
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

  Widget _buildPatientCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: Icon(isEditing ? Icons.save : Icons.edit, size: 18),
                label: Text(isEditing ? 'Save' : 'Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isEditing
              ? _buildEditableField(Icons.person, _firstNameController, _lastNameController)
              : _buildInfoRow(Icons.person, '${_firstNameController.text} ${_lastNameController.text}'),
          isEditing
              ? _buildEditableAgeRow(Icons.cake)
              : _buildInfoRow(Icons.cake, 'Age: $age'),
          isEditing
              ? _buildEditableSingleField(Icons.phone, _phoneController)
              : _buildInfoRow(Icons.phone, _phoneController.text),
          isEditing
              ? _buildEditableSingleField(Icons.email, _emailController)
              : _buildInfoRow(Icons.email, _emailController.text),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[700]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.blueGrey[800])),
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, TextEditingController first, TextEditingController last) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: first,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: last,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableAgeRow(IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
            onChanged: (value) {
              setState(() {
                age = int.tryParse(value) ?? age;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditableSingleField(IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitList() {
    return ListView.builder(
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              child: Text(visit['tooth'], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              'Date: ${visit['date']}',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey[800], fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Tooth: ${visit['tooth']}  •  Diagnosis: ${visit['diagnosis']}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show visit detail screen
            },
          ),
        );
      },
    );
  }
}
