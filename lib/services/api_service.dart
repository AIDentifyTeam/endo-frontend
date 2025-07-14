import 'dart:convert';
import 'package:endo_frontend/models/patient.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000/api';
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? _cachedProfile;

  Future<Map<String, dynamic>?> getCachedDoctorProfile() async {
    if (_cachedProfile != null) return _cachedProfile;

    final profile = await getDoctorProfile();
    if (profile != null) _cachedProfile = profile;
    return _cachedProfile;
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);
      return true;
    }
    return false;
  }

  Future<bool> registerDoctor({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final token = await storage.read(key: 'access');
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  void logout() async {
    await storage.delete(key: 'access');
    await storage.delete(key: 'refresh');
  }

  Future<Patient?> createPatient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String sex,
    required String birthDate,
  }) async {
    final token = await storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('$baseUrl/patients/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'sex': sex,
        'birth_date': birthDate,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Patient.fromJson(json);
    }

    return null;
  }

  Future<List<Patient>> getPatients() async {
    final token = await storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('$baseUrl/patients/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Patient.fromJson(json)).toList();
    }

    return [];
  }


}

