import 'package:flutter/material.dart';
import '../services/api/api_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  bool _isLoading = false;
  bool _isInitialAuthCheck = true;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  bool get isInitialAuthCheck => _isInitialAuthCheck;
  String? get error => _error;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.initialize();
      // Ideally, we should validate the token with the backend here
      // For now, we'll assume if a token exists, the user is authenticated
      // We might need to decode the token to get userId/name if not stored separately
      // But ApiService handles token storage.
      
      // Let's check if we have a token
      // Since ApiService.initialize() loads the token, we can check if it has one?
      // ApiService doesn't expose the token directly.
      // But we can try to fetch user details or just rely on a stored flag.
      // For better security, let's try to fetch user details or something.
      // But we don't have a "me" endpoint in the list.
      // We will assume if ApiService has a token (which we can't check directly easily without modifying ApiService to expose it),
      // actually ApiService.initialize() sets _token.
      
      // Let's add a method to ApiService to check if token exists
      final hasToken = await _apiService.hasToken();
      
      if (hasToken) {
        _isAuthenticated = true;
        // We might want to store userId/name in SharedPreferences too to restore them
        // For now, let's assume we need to re-login if we don't have user details
        // Or we can store them.
        // Let's update ApiService to store/retrieve user info as well.
        final userInfo = await _apiService.getUserInfo();
        if (userInfo != null) {
          _userId = userInfo['id'];
          _userName = userInfo['name'];
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      _isInitialAuthCheck = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(email, password, name);
      _userId = response['user']['id'];
      _userName = response['user']['name'];
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _userId = response['user']['id'];
      _userName = response['user']['name'];
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        _error = 'Incorrect username or password';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
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
