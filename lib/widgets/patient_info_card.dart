import 'package:flutter/material.dart';
import 'package:endo_frontend/models/patient.dart';

class PatientInfoCard extends StatelessWidget {
  final Patient patient;
  final bool isEditable;
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? phoneController;
  final TextEditingController? emailController;

  const PatientInfoCard({
    super.key,
    required this.patient,
    this.isEditable = false,
    this.firstNameController,
    this.lastNameController,
    this.phoneController,
    this.emailController,
  });

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final int age = _calculateAge(DateTime.parse(patient.birthDate));

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
          const Text(
            'Patient Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(height: 16),

          /// Row 1
          Row(
            children: [
              Expanded(
                child: isEditable
                    ? _buildEditableField(Icons.person, firstNameController!, lastNameController!)
                    : _buildColorInfo(Icons.person, '${patient.firstName} ${patient.lastName}', Colors.blue[100]!),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildColorInfo(Icons.cake, 'Age: $age', Colors.green[100]!),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Row 2
          Row(
            children: [
              Expanded(
                child: isEditable
                    ? _buildEditableSingleField(Icons.phone, phoneController!)
                    : _buildColorInfo(Icons.phone, patient.phone, Colors.orange[100]!),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isEditable
                    ? _buildEditableSingleField(Icons.email, emailController!)
                    : _buildColorInfo(Icons.email, patient.email, Colors.purple[100]!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorInfo(IconData icon, String text, Color bgColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(IconData icon, TextEditingController first, TextEditingController last) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: first, decoration: const InputDecoration(labelText: 'First Name'))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: last, decoration: const InputDecoration(labelText: 'Last Name'))),
      ],
    );
  }

  Widget _buildEditableSingleField(IconData icon, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: controller)),
      ],
    );
  }
}
