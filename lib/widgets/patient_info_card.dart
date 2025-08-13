import 'package:flutter/material.dart';
import 'package:endo_frontend/models/patient.dart';

class PatientInfoCard extends StatefulWidget {
  final Patient patient;
  final String? toothNumber;

  const PatientInfoCard({
    super.key,
    required this.patient,
    this.toothNumber,
  });

  @override
  State<PatientInfoCard> createState() => _PatientInfoCardState();
}

class _PatientInfoCardState extends State<PatientInfoCard> {
  bool isEditing = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.patient.firstName);
    _lastNameController =
        TextEditingController(text: widget.patient.lastName);
    _phoneController =
        TextEditingController(text: widget.patient.phone ?? '');
    _emailController =
        TextEditingController(text: widget.patient.email ?? '');
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    // Safe age computation
    final String? birthStr = widget.patient.birthDate;
    final DateTime? dob = (birthStr != null && birthStr.trim().isNotEmpty)
        ? DateTime.tryParse(birthStr)
        : null;
    final int? age = (dob != null) ? _calculateAge(dob) : null;

    final String phone = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String? tooth = (widget.toothNumber?.trim().isEmpty ?? true)
        ? null
        : widget.toothNumber!.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Title + Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                    // TODO: hook save logic when turning off editing if needed
                  });
                },
                icon: Icon(isEditing ? Icons.save : Icons.edit, size: 18),
                label: Text(isEditing ? 'Save' : 'Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEditing ? Colors.green : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 1: Name + (optional) Age
          Row(
            children: [
              Expanded(
                child: isEditing
                    ? _buildEditableField(
                        Icons.person, _firstNameController, _lastNameController)
                    : _buildColorInfo(
                        Icons.person,
                        '${_firstNameController.text} ${_lastNameController.text}',
                        Colors.blue[100]!,
                      ),
              ),
              if (age != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColorInfo(
                    Icons.cake_outlined,
                    'Age: $age',
                    Colors.green[100]!,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: (optional) Phone + (optional) Email
          Row(
            children: [
              if (!isEditing && phone.isNotEmpty) ...[
                Expanded(
                  child: _buildColorInfo(
                    Icons.phone,
                    phone,
                    Colors.orange[100]!,
                  ),
                ),
              ] else if (isEditing) ...[
                Expanded(
                  child: _buildEditableSingleField(
                    Icons.phone,
                    _phoneController,
                  ),
                ),
              ],
              if (!isEditing && phone.isNotEmpty && (email.isNotEmpty || isEditing))
                const SizedBox(width: 16),
              if (!isEditing && email.isNotEmpty) ...[
                Expanded(
                  child: _buildColorInfo(
                    Icons.email_outlined,
                    email,
                    Colors.purple[100]!,
                  ),
                ),
              ] else if (isEditing) ...[
                if (phone.isNotEmpty) const SizedBox(width: 16),
                Expanded(
                  child: _buildEditableSingleField(
                    Icons.email_outlined,
                    _emailController,
                  ),
                ),
              ],
            ],
          ),

          if (tooth != null) ...[
            const SizedBox(height: 12),
            // Row 3: Tooth number (optional)
            Row(
              children: [
                Expanded(
                  child: _buildColorInfo(
                    Icons.confirmation_number,
                    'Tooth #: $tooth',
                    Colors.cyan[100]!,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorInfo(IconData icon, String text, Color bgColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
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

  Widget _buildEditableField(
      IconData icon,
      TextEditingController first,
      TextEditingController last,
  ) {
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

  Widget _buildEditableSingleField(
      IconData icon,
      TextEditingController controller,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: controller)),
      ],
    );
  }
}
