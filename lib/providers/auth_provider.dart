// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        _token = token;
        // Parse user from JSON string
        // _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      if (response['success'] == true) {
        _token = response['token'];
        _user = User.fromJson(response['user']);

        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        // await prefs.setString('user', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(userData);
      
      if (response['success'] == true) {
        _token = response['token'];
        _user = User.fromJson(response['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}