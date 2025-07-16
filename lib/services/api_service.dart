import 'dart:convert';
import 'dart:io';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/notifications.dart';
import 'package:flutter/material.dart';
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

  void clearDoctorProfileCache() {
    _cachedProfile = null;
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await storage.read(key: 'access');
    final response = await http.put(
      Uri.parse('$baseUrl/change-password/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password.');
    }
  }

  Future<bool> deleteAccount() async {
    final token = await storage.read(key: 'access');
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-account/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      return true; // Deletion success, caller should now logout
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete account.');
    }
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

  Future<bool> updateDoctorProfile({
    required String firstName,
    required String lastName,
    File? profileImage,
  }) async {
    final token = await storage.read(key: 'access');
    final uri = Uri.parse('$baseUrl/profile/');

    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;

    if (profileImage != null) {
      final fileStream = await http.MultipartFile.fromPath('profile_image', profileImage.path);
      request.files.add(fileStream);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return response.statusCode == 200;
  }


  Future<void> logout() async {
    final refresh = await storage.read(key: 'refresh');
    final access = await storage.read(key: 'access');

    if (refresh == null || access == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access',
      },
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Logout failed: ${response.statusCode}');
    }
  }


  Future<void> clearTokens() async {
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

  Future<List<dynamic>?> getVisits() async {
    final url = Uri.parse('$baseUrl/visits/');
    final token = await storage.read(key: 'access');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to fetch visit history');
    }
  }


  Future<List<Map<String, dynamic>>> fetchVisitHistory(int patientId) async {
      final token = await storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('$baseUrl/visits/?patient=$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Failed to fetch visit history');
      }
    }

  Future<int> createVisit({
    required int patientId,
    required String toothNumber,
    required Map<String, dynamic> answers,
    required String pulpDiagnosis,
    required String periapicalDisease,
    required String etiology,
    File? toothImage, // <- New optional parameter
  }) async {
    final token = await storage.read(key: 'access');
    final uri = Uri.parse('$baseUrl/visits/');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['patient'] = patientId.toString()
      ..fields['tooth_number'] = toothNumber
      ..fields['answers'] = jsonEncode(answers)
      ..fields['pulp_diagnosis'] = pulpDiagnosis
      ..fields['periapical_disease'] = periapicalDisease
      ..fields['etiology'] = etiology;

    if (toothImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'tooth_image',
        toothImage.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['id']; // return visitId
    } else {
      throw Exception('Failed to create visit: ${response.body}');
    }
  }



  Future<Map<String, dynamic>> fetchVisitById(int visitId) async {
    final token = await storage.read(key: 'access'); // Make sure this is correct
    final url = Uri.parse('$baseUrl/visits/$visitId/'); // Must have trailing slash

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch visit: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final token = await storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('$baseUrl/notification-status/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        return NotificationItem(
          id: json['id'].toString(),
          title: json['title'] ?? 'Untitled',
          description: json['description'] ?? '',
          type: json['type'] ?? 'Notification',
          timestamp: DateTime.parse(json['timestamp']),
          isRead: json['is_read'] ?? false,
        );
      }).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }


}

