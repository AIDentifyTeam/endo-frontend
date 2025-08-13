import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'dart:convert';
import 'dart:io';
import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String baseUrl = 'https://aidentify.app';
// const String baseUrl = 'http://127.0.0.1:8000';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}


class ApiService {
  final String apiUrl = '$baseUrl/api';
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
        Uri.parse('$apiUrl/token/'),
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
      Uri.parse('$apiUrl/register/'),
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
      Uri.parse('$apiUrl/change-password/'),
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
      Uri.parse('$apiUrl/delete-account/'),
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
      Uri.parse('$apiUrl/profile/'),
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
    Uint8List? webImageBytes,
  }) async {
    final token = await storage.read(key: 'access');
    final uri = Uri.parse('$apiUrl/profile/');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['first_name'] = firstName
      ..fields['last_name'] = lastName;

    if (kIsWeb && webImageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'profile_image',
        webImageBytes,
        filename: 'profile.png',
        contentType: MediaType('image', 'png'),
      ));
    } else if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage.path,
      ));
    }

    final streamed = await request.send();
    return streamed.statusCode == 200;
  }



  Future<void> logout() async {
    final refresh = await storage.read(key: 'refresh');
    final access = await storage.read(key: 'access');

    if (refresh == null || access == null) return;

    final response = await http.post(
      Uri.parse('$apiUrl/logout/'),
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
    String? patientId, // optional, backend generates if null
    String? email,
    String? phone,
    String? sex,
    String? birthDate, // YYYY-MM-DD
  }) async {
    final token = await storage.read(key: 'access');

    String? _nn(String? v) =>
    (v == null || v.trim().isEmpty) ? null : v.trim();

    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      if (_nn(patientId) != null) 'patient_id': _nn(patientId),
      if (_nn(email) != null) 'email': _nn(email),
      if (_nn(phone) != null) 'phone': _nn(phone),
      if (_nn(sex) != null) 'sex': _nn(sex),
      if (_nn(birthDate) != null) 'birth_date': _nn(birthDate),
    };

    final response = await http.post(
      Uri.parse('$apiUrl/patients/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    }

    // Handle validation errors
    if (response.statusCode == 400) {
      try {
        final err = jsonDecode(response.body);
        if (err is Map) {
          final keys = err.keys.map((e) => e.toString()).toSet();
          if (keys.contains('email') || keys.contains('phone')) {
            throw ApiException(
              'Failed to create new patient, please enter a valid phone number/email.',
            );
          }
          if (err['detail'] is String) throw ApiException(err['detail']);
          for (final v in err.values) {
            if (v is List && v.isNotEmpty && v.first is String) {
              throw ApiException(v.first as String);
            }
          }
        }
      } catch (_) {
        // ignore parse issues
      }
    }

    throw ApiException('Failed to create patient');
  }

  Future<List<Patient>> getPatients() async {
    final token = await storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('$apiUrl/patients/'),
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
    final url = Uri.parse('$apiUrl/visits/');
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
        Uri.parse('$apiUrl/visits/?patient=$patientId'),
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
    String? pulpDiagnosis,
    String? periapicalDisease,
    String? etiology,
    XFile? toothImage,
    Uint8List? webImageBytes,
  }) async {
    final token = await storage.read(key: 'access');
    final uri = Uri.parse('$apiUrl/visits/');

    String? _nn(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['patient'] = patientId.toString()
      ..fields['tooth_number'] = toothNumber
      ..fields['answers'] = jsonEncode(answers);

    if (_nn(pulpDiagnosis) != null) request.fields['pulp_diagnosis'] = _nn(pulpDiagnosis)!;
    if (_nn(periapicalDisease) != null) request.fields['periapical_disease'] = _nn(periapicalDisease)!;
    if (_nn(etiology) != null) request.fields['etiology'] = _nn(etiology)!;

    if (toothImage != null) {
      if (kIsWeb) {
        // 🟢 Flutter Web: Use fromBytes
        if (webImageBytes == null) {
          throw Exception("Web image bytes are null.");
        }
        request.files.add(http.MultipartFile.fromBytes(
          'tooth_image',
          webImageBytes,
          filename: toothImage.name,
          contentType: MediaType('image', 'png'), // or 'jpeg' based on file
        ));
      } else {
        // ✅ Mobile/Desktop: Use fromPath
        request.files.add(await http.MultipartFile.fromPath(
          'tooth_image',
          toothImage.path,
        ));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['id']; // return visitId
    } else {
      if (response.statusCode == 400) {
        try {
          final err = jsonDecode(response.body);
          if (err is Map) {
            for (final v in err.values) {
              if (v is List && v.isNotEmpty && v.first is String) {
                throw ApiException(v.first);
              }
            }
          }
        } catch (_) {}
      }
      throw ApiException('Failed to create visit');

    }
  }



  Future<Map<String, dynamic>> fetchVisitById(int visitId) async {
    final token = await storage.read(key: 'access'); // Make sure this is correct
    final url = Uri.parse('$apiUrl/visits/$visitId/'); // Must have trailing slash

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
      Uri.parse('$apiUrl/notification-status/'),
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

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final token = await storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('$baseUrl/api/notification-status/'), // baseUrl should be defined globally
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) {
          final notif = json['notification'] ?? {};
          return NotificationItem(
            id: json['id']?.toString() ?? '',
            title: notif['title'] ?? 'Untitled',
            description: notif['description'] ?? '',
            type: notif['category'] ?? 'notification',
            timestamp: DateTime.tryParse(notif['created_at'] ?? '') ?? DateTime.now(),
            isRead: json['is_read'] ?? false,
          );
        }).toList();
      } else {
        throw Exception('Failed to load notifications. Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await storage.read(key: 'access');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/notification-status/$notificationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_read': true}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read. Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }


}


