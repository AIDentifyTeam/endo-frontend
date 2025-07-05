// lib/models/patient.dart
class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String phone;
  final String email;
  final String lastVisit;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.phone,
    required this.email,
    required this.lastVisit,
  });
}
