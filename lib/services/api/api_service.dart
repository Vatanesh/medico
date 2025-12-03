import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Initialize token from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  // Save token and user info
  Future<void> saveToken(String token, {Map<String, dynamic>? userInfo}) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    
    if (userInfo != null) {
      if (userInfo.containsKey('id')) {
        await prefs.setString(AppConstants.userIdKey, userInfo['id']);
      }
      if (userInfo.containsKey('name')) {
        await prefs.setString('user_name', userInfo['name']);
      }
    }
  }

  // Clear token and user info
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove('user_name');
  }

  // Check if token exists
  Future<bool> hasToken() async {
    if (_token != null) return true;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    return _token != null;
  }

  // Get stored user info
  Future<Map<String, String>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(AppConstants.userIdKey);
    final name = prefs.getString('user_name');
    
    if (id != null && name != null) {
      return {'id': id, 'name': name};
    }
    return null;
  }

  // Get headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Register user
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token'], userInfo: data['user']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.login),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token'], userInfo: data['user']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(error['error'] ?? 'Login failed', response.statusCode);
    }
  }

  // Get patients
  Future<List<dynamic>> getPatients(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.patients}?userId=$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['patients'] ?? [];
    } else {
      throw Exception('Failed to load patients');
    }
  }

  // Add patient
  Future<Map<String, dynamic>> addPatient(Map<String, dynamic> patientData) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.addPatient),
      headers: _getHeaders(),
      body: jsonEncode(patientData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['patient'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to add patient');
    }
  }

  // Get patient details
  Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.patientDetails(patientId)),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  // Create recording session
  Future<String> createSession(Map<String, dynamic> sessionData) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.uploadSession),
      headers: _getHeaders(),
      body: jsonEncode(sessionData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create session');
    }
  }

  // Get presigned URL
  Future<Map<String, dynamic>> getPresignedUrl(
    String sessionId,
    int chunkNumber,
    String mimeType,
  ) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.getPresignedUrl),
      headers: _getHeaders(),
      body: jsonEncode({
        'sessionId': sessionId,
        'chunkNumber': chunkNumber,
        'mimeType': mimeType,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get presigned URL');
    }
  }

  // Upload chunk to presigned URL
  Future<void> uploadChunk(String presignedUrl, List<int> audioData) async {
    try {
      print('[UPLOAD] Uploading ${audioData.length} bytes to: $presignedUrl');
      
      final response = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': AppConstants.audioMimeType,
        },
        body: audioData,
      );

      print('[UPLOAD] Response status: ${response.statusCode}');
      print('[UPLOAD] Response body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to upload chunk: ${response.statusCode} - ${response.body}');
      }
      
      print('[UPLOAD] Chunk uploaded successfully');
    } catch (e) {
      print('[UPLOAD ERROR] $e');
      rethrow;
    }
  }

  // Notify chunk uploaded
  Future<void> notifyChunkUploaded(Map<String, dynamic> chunkData) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.notifyChunkUploaded),
      headers: _getHeaders(),
      body: jsonEncode(chunkData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to notify chunk uploaded');
    }
  }

  // Get sessions by patient
  Future<List<dynamic>> getSessionsByPatient(String patientId) async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.fetchSessionByPatient(patientId)),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['sessions'] ?? [];
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // Get all sessions
  Future<Map<String, dynamic>> getAllSessions(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.allSessions}?userId=$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // Get templates
  Future<List<dynamic>> getTemplates(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.fetchDefaultTemplate}?userId=$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load templates');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
