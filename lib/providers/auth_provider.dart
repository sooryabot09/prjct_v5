// lib/providers/auth_provider.dart - FIXED VERSION WITH DEBUGGING
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      print('📦 Loading user from storage...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      print('   Token exists: ${token != null}');
      print('   User data exists: ${userJson != null}');

      if (token != null && userJson != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userJson));
        ApiService.setToken(token);
        print('✅ User loaded from storage: ${_user?.email}');
        notifyListeners();
      } else {
        print('⚠️  No stored user data found');
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
      _errorMessage = e.toString();
    }
  }

  Future<bool> login(String email, String password) async {
    print('\n🔐 Starting login process...');
    print('   Email: $email');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Calling API login...');
      final response = await ApiService.login(email, password);
      
      print('📥 Login response received:');
      print('   Success: ${response['success']}');
      print('   Has token: ${response['token'] != null}');
      print('   Has user: ${response['user'] != null}');
      
      if (response['success'] == true) {
        if (response['token'] == null || response['user'] == null) {
          throw Exception('Invalid response: missing token or user data');
        }

        _token = response['token'];
        print('✅ Token extracted: ${_token?.substring(0, 20)}...');
        
        print('👤 Parsing user data...');
        _user = User.fromJson(response['user']);
        print('✅ User parsed: ${_user?.email} (${_user?.role})');

        // Save to storage
        print('💾 Saving to storage...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        print('✅ Saved to storage');

        // Set token in API service
        ApiService.setToken(_token);
        print('✅ Token set in API service');

        _isLoading = false;
        notifyListeners();
        
        print('✅ LOGIN SUCCESSFUL!\n');
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Login failed';
        print('❌ Login failed: $_errorMessage\n');
      }
    } catch (e, stackTrace) {
      print('❌ Login exception: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    print('❌ LOGIN FAILED\n');
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    print('\n📝 Starting registration process...');
    print('   Email: ${userData['email']}');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Calling API register...');
      final response = await ApiService.register(userData);
      
      print('📥 Registration response received:');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true) {
        print('✅ REGISTRATION SUCCESSFUL');
        
        // Check if we got a token (might be null if backend doesn't return it)
        if (response['token'] != null) {
          _token = response['token'];
          _user = User.fromJson(response['user']);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(_user!.toJson()));
          
          ApiService.setToken(_token);
          print('✅ User auto-logged in after registration');
        } else {
          print('⚠️  No token in response, registration successful but not auto-logged in');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Registration failed';
        print('❌ Registration failed: $_errorMessage');
      }
    } catch (e, stackTrace) {
      print('❌ Registration exception: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    print('❌ REGISTRATION FAILED\n');
    return false;
  }

  Future<void> logout() async {
    print('🚪 Logging out...');
    _user = null;
    _token = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    ApiService.setToken(null);
    print('✅ Logout complete\n');

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
    
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user', jsonEncode(user.toJson()));
    });
  }

  Future<void> refreshUser() async {
    await _loadUserFromStorage();
  }
}