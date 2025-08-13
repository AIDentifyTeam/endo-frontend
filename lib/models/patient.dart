class Patient {
  final int id;
  final String? patientId; // optional from backend
  final String firstName;
  final String lastName;
  final String? birthDate; // optional
  final String? phone; // optional
  final String? email; // optional
  final String createdAt;
  final String updatedAt;

  Patient({
    required this.id,
    this.patientId,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phone,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    String? _nn(dynamic v) =>
        (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    return Patient(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      patientId: _nn(json['patient_id']),
      firstName: json['first_name']?.toString().trim() ?? '',
      lastName: json['last_name']?.toString().trim() ?? '',
      birthDate: _nn(json['birth_date']),
      phone: _nn(json['phone']),
      email: _nn(json['email']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'patient_id': patientId,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'phone': phone,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    // Remove nulls so we don’t send empty values to backend
    map.removeWhere((_, v) => v == null);
    return map;
  }

  /// Returns patient's age, or null if birthDate is missing/invalid.
  int? get age {
    if (birthDate == null || birthDate!.trim().isEmpty) return null;
    final dob = DateTime.tryParse(birthDate!);
    if (dob == null) return null;

    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }
}
