import 'package:flutter/material.dart';
import '../services/api/api_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Auto-login for demo purposes
  Future<void> autoLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to register demo user (will fail if already exists)
      try {
        final registerResponse = await _apiService.register(
          'demo@medinote.app',
          'demo123456',
          'Demo User',
        );
        _userId = registerResponse['user']['id'];
        _userName = registerResponse['user']['name'];
        _isAuthenticated = true;
      } catch (e) {
        // User might already exist, try login
        final loginResponse = await _apiService.login(
          'demo@medinote.app',
          'demo123456',
        );
        _userId = loginResponse['user']['id'];
        _userName = loginResponse['user']['name'];
        _isAuthenticated = true;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Authentication failed: ${e.toString()}';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}
