// lib/providers/auth_provider.dart
import 'dart:convert';
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
        _user = User.fromJson(jsonDecode(userJson));
        ApiService.setToken(token);
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
        await prefs.setString('user', jsonEncode(_user!.toJson()));

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
      print('📝 AuthProvider: Starting registration...');
      final response = await ApiService.register(userData);
      
      print('📥 AuthProvider: Registration response: $response');
      
      if (response['success'] == true) {
        print('✅ AuthProvider: Registration successful');
        
        // Check if we got a token (might be null if backend doesn't return it)
        if (response['token'] != null) {
          _token = response['token'];
          _user = User.fromJson(response['user']);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(_user!.toJson()));
          
          print('✅ AuthProvider: User data saved');
        } else {
          print('⚠️ AuthProvider: No token in response, registration successful but not auto-logged in');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('❌ AuthProvider: Registration failed - success=false');
        print('   Error: ${response['error']}');
      }
    } catch (e) {
      print('❌ AuthProvider: Registration exception: $e');
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

    ApiService.setToken(null);

    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
    
    // Also update in storage
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user', jsonEncode(user.toJson()));
    });
  }

  Future<void> refreshUser() async {
    // This would typically call an API endpoint to get fresh user data
    // For now, just reload from storage
    await _loadUserFromStorage();
  }
}