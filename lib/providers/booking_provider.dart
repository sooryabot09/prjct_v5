// lib/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await ApiService.getBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createBooking(bookingData);
      if (response['success'] == true) {
        await loadBookings();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating booking: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await ApiService.updateBookingStatus(bookingId, status);
      if (response['success'] == true) {
        await loadBookings();
        return true;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  void clearBookings() {
    _bookings = [];
    notifyListeners();
  }
}