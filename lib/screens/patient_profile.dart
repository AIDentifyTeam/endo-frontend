import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';
import 'package:endo_frontend/widgets/global_header.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  final Map<String, dynamic> patient = const {
    'name': 'John Doe',
    'age': 29,
    'phone': '(555) 123-4567',
    'email': 'john.doe@email.com',
  };

  final List<Map<String, dynamic>> visits = const [
    {
      'tooth': '12',
      'date': '2025-06-30',
      'diagnosis': 'Pulpitis',
    },
    {
      'tooth': '26',
      'date': '2025-05-15',
      'diagnosis': 'Necrotic Pulp',
    },
  ];

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
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Diagnosis',
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

  Widget _buildPatientCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // ✅ changed from light blue to white
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, patient['name']),
          _buildInfoRow(Icons.cake, 'Age: ${patient['age']}'),
          _buildInfoRow(Icons.phone, patient['phone']),
          _buildInfoRow(Icons.email, patient['email']),
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
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.blueGrey[800]),
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
          color: Colors.white, // ✅ changed from light pink to white
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                visit['tooth'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'Date: ${visit['date']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
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
