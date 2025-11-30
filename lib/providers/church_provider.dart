// lib/providers/church_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ChurchProvider with ChangeNotifier {
  List<Church> _churches = [];
  Church? _selectedChurch;
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Church> get churches => _churches;
  Church? get selectedChurch => _selectedChurch;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChurches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _churches = await ApiService.getChurches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectChurch(int churchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedChurch = await ApiService.getChurchById(churchId);
      await loadServices(churchId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices(int churchId) async {
    try {
      _services = await ApiService.getServicesByChurch(churchId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedChurch = null;
    _services = [];
    notifyListeners();
  }
}