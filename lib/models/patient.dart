class Patient {
  final int id;
  final String? patientId;   // optional from backend
  final String firstName;
  final String lastName;
  final String? birthDate;   // optional
  final String? phone;       // optional
  final String? email;       // optional
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
    return Patient(
      id: json['id'] ?? 0,
      patientId: json['patient_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthDate: json['birth_date'],
      phone: json['phone'],
      email: json['email'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  /// Returns patient's age, or null if birthDate is missing/invalid.
  int? get age {
    if (birthDate == null || birthDate!.trim().isEmpty) return null;
    final dob = DateTime.tryParse(birthDate!);
    if (dob == null) return null;

    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }
}
