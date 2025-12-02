// lib/services/service_manager.dart
import 'package:flutter/foundation.dart';
import 'package:prjct_v5/services/api_service.dart';
import '../models/user.dart';

class ServiceManager with ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load services for a specific church
  Future<void> loadServices(int churchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await ApiService.getServicesByChurch(churchId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new service
  Future<bool> createService({
    required String name,
    required String description,
    required double amount,
    required int churchId,
    required List<Map<String, dynamic>> splits,
  }) async {
    try {
      final serviceData = {
        'name': name,
        'description': description,
        'amount_paise': (amount * 100).toInt(),
        'church_id': churchId,
        'splits': splits,
      };

      final response = await ApiService.createService(serviceData);
      if (response['success'] == true) {
        await loadServices(churchId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update service
  Future<bool> updateService({
    required int serviceId,
    required String name,
    required String description,
    required double amount,
    List<Map<String, dynamic>>? splits,
  }) async {
    try {
      final serviceData = {
        'name': name,
        'description': description,
        'amount_paise': (amount * 100).toInt(),
        if (splits != null) 'splits': splits,
      };

      final response = await ApiService.updateService(serviceId, serviceData);
      return response['success'] == true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete service
  Future<bool> deleteService(int serviceId, int churchId) async {
    try {
      final response = await ApiService.deleteService(serviceId);
      if (response['success'] == true) {
        await loadServices(churchId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

