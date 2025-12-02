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
      print('📡 ChurchProvider: Loading churches...');
      _churches = await ApiService.getChurches();
      print('✅ ChurchProvider: Loaded ${_churches.length} churches');
      
      // Debug: Print church details
      for (var church in _churches) {
        print('   - ${church.name} (ID: ${church.churchId})');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ ChurchProvider: Error loading churches: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so the UI can catch it
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