import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart'; // MediaType
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:endo_frontend/models/patient.dart';
import 'package:endo_frontend/screens/notifications.dart';
import 'package:endo_frontend/app_navigator.dart';
import 'package:endo_frontend/routes.dart';

const String baseUrl = 'https://aidentify.app';
// const String baseUrl = 'http://localhost:8000';

// Global toast helper (uses navigatorKey context)
void _notify(String msg) {
  final ctx = appNavigatorKey.currentContext;
  if (ctx != null) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {

  // --- Singleton wiring ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  final String apiUrl = '$baseUrl/api';
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? _cachedProfile;



  // --- Global guards shared by ALL instances ---
  static Completer<bool>? _refreshing;
  static bool _clearingTokens = false;

  /// Try a refresh once (used by splash/login silent sign-in)
  Future<bool> tryRefreshOnce() => _refreshAccessToken();

  Future<bool> _refreshAccessToken() async {
    // If a refresh is already in progress, wait for it
    if (_refreshing != null) return _refreshing!.future;

    final c = Completer<bool>();
    _refreshing = c;

    try {
      final refresh = await storage.read(key: 'refresh');
      if (refresh == null || refresh.isEmpty) {
        c.complete(false);
        return c.future;
      }

      final resp = await http.post(
        Uri.parse('$apiUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        // SimpleJWT may return BOTH access and (if rotation enabled) NEW refresh
        final newAccess = data['access'] as String?;
        final newRefresh = data['refresh'] as String?;

        if (newAccess != null) {
          await storage.write(key: 'access', value: newAccess);
        }
        if (newRefresh != null) {
          // CRITICAL: store rotated refresh; old one is now invalid/blacklisted
          await storage.write(key: 'refresh', value: newRefresh);
        }

        c.complete(newAccess != null);
      } else {
        c.complete(false);
      }
    } catch (_) {
      c.complete(false);
    } finally {
      _refreshing = null; // allow future refreshes
    }

    return c.future;
  }


  Future<void> _safeDelete(String key) async {
    // Windows can lock the secure storage file briefly
    for (var i = 0; i < 3; i++) {
      try {
        await storage.delete(key: key);
        return;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    // Fallback overwrite
    try {
      await storage.write(key: key, value: '');
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    if (_clearingTokens) return;
    _clearingTokens = true;
    try {
      await _safeDelete('access');
      await _safeDelete('refresh');
    } finally {
      _clearingTokens = false;
    }
  }

  Future<void> _forceLogoutToLogin() async {
    // Navigate first so UI stops issuing requests
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (r) => false,
    );
    // Then clear tokens
    await clearTokens();
  }

  /// Centralized sender for JSON requests.
  /// Returns a synthetic 401 Response instead of throwing when session is invalid.
  Future<http.Response> _sendAuthorized(
    Future<http.Response> Function(String accessToken) doRequest,
  ) async {
    String? access = await storage.read(key: 'access');
    if (access == null) {
      _notify('Please log in to continue.');
      await _forceLogoutToLogin();
      return http.Response('', 401);
    }

    var response = await doRequest(access);

    if (response.statusCode == 401) {
      final ok = await _refreshAccessToken();
      if (!ok) {
        _notify('Session expired. Please log in again.');
        await _forceLogoutToLogin();
        return http.Response('', 401);
      }
      access = await storage.read(key: 'access');
      response = await doRequest(access!);

      if (response.statusCode == 401) {
        _notify('Session expired. Please log in again.');
        await _forceLogoutToLogin();
        return http.Response('', 401);
      }
    }
    return response;
  }

  /// Centralized sender for multipart uploads.
  /// Returns a synthetic 401 StreamedResponse instead of throwing when session is invalid.
  Future<http.StreamedResponse> _sendAuthorizedMultipart(
    Future<http.MultipartRequest> Function(String accessToken) buildRequestWithToken,
  ) async {
    String? access = await storage.read(key: 'access');
    if (access == null) {
      _notify('Please log in to continue.');
      await _forceLogoutToLogin();
      return http.StreamedResponse(Stream<List<int>>.empty(), 401);
    }

    http.MultipartRequest req = await buildRequestWithToken(access);
    var streamed = await req.send();

    if (streamed.statusCode == 401) {
      final ok = await _refreshAccessToken();
      if (!ok) {
        _notify('Session expired. Please log in again.');
        await _forceLogoutToLogin();
        return http.StreamedResponse(Stream<List<int>>.empty(), 401);
      }
      access = await storage.read(key: 'access');
      req = await buildRequestWithToken(access!);
      streamed = await req.send();

      if (streamed.statusCode == 401) {
        _notify('Session expired. Please log in again.');
        await _forceLogoutToLogin();
        return http.StreamedResponse(Stream<List<int>>.empty(), 401);
      }
    }
    return streamed;
  }

  // --- Profile cache --------------------------------------------------------

  Future<Map<String, dynamic>?> getCachedDoctorProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    final profile = await getDoctorProfile();
    if (profile != null) _cachedProfile = profile;
    return _cachedProfile;
  }

  void clearDoctorProfileCache() {
    _cachedProfile = null;
  }

  // --- Auth endpoints -------------------------------------------------------

  Future<bool> login(String username, String password, {bool rememberMe = true}) async {
    final response = await http.post(
      Uri.parse('$apiUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
      if (rememberMe) {
        await storage.write(key: 'refresh', value: data['refresh']);
      } else {
        await storage.delete(key: 'refresh');
      }
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final refresh = await storage.read(key: 'refresh');
    final access = await storage.read(key: 'access');

    if (refresh == null || access == null) {
      await clearTokens();
      return;
    }

    final response = await http.post(
      Uri.parse('$apiUrl/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access',
      },
      body: jsonEncode({'refresh': refresh}),
    );

    await clearTokens();

    if (response.statusCode != 204 && response.statusCode != 200) {
      // Non-fatal; already cleared locally.
    }
  }

  // --- Doctor/Profile -------------------------------------------------------

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
    final response = await _sendAuthorized(
      (token) => http.put(
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
      ),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password.');
    }
  }

  Future<bool> deleteAccount() async {
    final response = await _sendAuthorized(
      (token) => http.delete(
        Uri.parse('$apiUrl/delete-account/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to delete account.');
    }
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
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
    final streamed = await _sendAuthorizedMultipart((token) async {
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
      return request;
    });

    return streamed.statusCode == 200;
  }

  // --- Patients & Visits ----------------------------------------------------

  Future<Patient?> createPatient({
    required String firstName,
    required String lastName,
    String? patientId,
    String? email,
    String? phone,
    String? sex,
    String? birthDate,
  }) async {
    String? nn(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      if (nn(patientId) != null) 'patient_id': nn(patientId),
      if (nn(email) != null) 'email': nn(email),
      if (nn(phone) != null) 'phone': nn(phone),
      if (nn(sex) != null) 'sex': nn(sex),
      if (nn(birthDate) != null) 'birth_date': nn(birthDate),
    };

    final response = await _sendAuthorized(
      (token) => http.post(
        Uri.parse('$apiUrl/patients/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ),
    );

    if (response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    }

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
      } catch (_) {}
    }
    throw ApiException('Failed to create patient');
  }

  Future<List<Patient>> getPatients() async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/patients/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Patient.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<dynamic>?> getVisits() async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/visits/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to fetch visit history');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVisitHistory(int patientId) async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/visits/?patient=$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to fetch visit history');
    }
  }

  Future<Map<String, dynamic>> createVisit({
    required int patientId,
    required String toothNumber,
    required Map<String, dynamic> answers,
    XFile? toothImage,
    Uint8List? webImageBytes,
  }) async {
    final streamedResponse = await _sendAuthorizedMultipart((token) async {
      final uri = Uri.parse('$apiUrl/visits/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['patient'] = patientId.toString()
        ..fields['tooth_number'] = toothNumber
        ..fields['answers'] = jsonEncode(answers);

      if (toothImage != null) {
        if (kIsWeb) {
          if (webImageBytes == null) {
            throw ApiException('Image data missing.');
          }
          request.files.add(http.MultipartFile.fromBytes(
            'tooth_image',
            webImageBytes,
            filename: toothImage.name,
            contentType: MediaType('image', 'png'),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'tooth_image',
            toothImage.path,
          ));
        }
      }
      return request;
    });

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      // Return the whole Visit JSON so UI can branch on results.source
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    // Bubble up server-side field errors (incl. case_id unique)
    if (response.statusCode == 400 || response.statusCode == 409 || response.statusCode == 422) {
      try {
        final err = jsonDecode(response.body);
        if (err is Map<String, dynamic>) {
          // Prefer first field error message
          for (final entry in err.entries) {
            final v = entry.value;
            if (v is List && v.isNotEmpty && v.first is String) {
              throw ApiException('${entry.key}: ${v.first}');
            } else if (v is String) {
              throw ApiException('${entry.key}: $v');
            }
          }
          // or a non-field error
          if (err['detail'] is String) throw ApiException(err['detail']);
        }
      } catch (_) {
        // fall through
      }
    }

    throw ApiException('Failed to create visit (${response.statusCode}).');
  }


  Future<Map<String, dynamic>> fetchVisitById(int visitId) async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/visits/$visitId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch visit: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateVisit({
    required int visitId,
    Map<String, dynamic>? fields,        // for JSON fields like answers, tooth_number, etc.
    XFile? toothImage,                   // optional new image
    Uint8List? webImageBytes,            // web-only image
    bool? removeToothImage,              // explicit remove flag
  }) async {
    final streamed = await _sendAuthorizedMultipart((token) async {
      final uri = Uri.parse('$apiUrl/visits/$visitId/');
      final request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $token';

      if (fields != null) {
        fields.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              request.fields[key] = jsonEncode(value);
            } else {
              request.fields[key] = value.toString();
            }
          }
        });
      }

      if (removeToothImage == true) {
        request.fields['remove_tooth_image'] = 'true';
      }

      if (toothImage != null) {
        if (kIsWeb) {
          if (webImageBytes == null) {
            throw Exception("Web image bytes are null.");
          }
          request.files.add(http.MultipartFile.fromBytes(
            'tooth_image',
            webImageBytes,
            filename: toothImage.name,
            contentType: MediaType('image', 'png'),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'tooth_image',
            toothImage.path,
          ));
        }
      }

      return request;
    });

    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException('Failed to update visit: ${response.statusCode} ${response.body}');
  }

  Future<void> deleteVisit(int visitId) async {
    final response = await _sendAuthorized(
      (token) => http.delete(
        Uri.parse('$apiUrl/visits/$visitId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException('Failed to delete visit: ${response.statusCode} ${response.body}');
    }
  }


  // --- Notifications --------------------------------------------------------

  Future<List<NotificationItem>> fetchNotifications() async {
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/notification-status/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
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
    final response = await _sendAuthorized(
      (token) => http.get(
        Uri.parse('$apiUrl/notification-status/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
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
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final response = await _sendAuthorized(
      (token) => http.patch(
        Uri.parse('$apiUrl/notification-status/$notificationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_read': true}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read. Code ${response.statusCode}');
    }
  }

}
