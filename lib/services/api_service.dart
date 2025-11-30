// lib/services/api_service.dart - FIXED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  // IMPORTANT: Update this for your environment
  // Android Emulator: 'http://10.0.2.2:3000/api'
  // iOS Simulator: 'http://localhost:3000/api'
  // Physical Device: 'http://YOUR_IP:3000/api'
  static const String baseUrl = 'http://192.168.18.129:3000/api';

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ==================== AUTH ENDPOINTS ====================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('🔐 Attempting login for: $email');
      print('📡 API URL: $baseUrl/auth/login');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('📥 Login response status: ${response.statusCode}');
      print('📥 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          setToken(data['token']);
        }
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Login failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      print('📝 Attempting registration for: ${userData['email']}');
      print('📡 API URL: $baseUrl/auth/register');
      print('📤 Request data: ${jsonEncode(userData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if backend is running.',
              );
            },
          );

      print('📥 Register response status: ${response.statusCode}');
      print('📥 Register response body: ${response.body}');

      // Parse response regardless of status code
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('❌ Failed to parse response JSON: $e');
        throw Exception('Invalid response from server');
      }

      // Success codes: 200 or 201
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Registration API call successful');

        // Check if response has success flag
        if (data['success'] == true) {
          if (data['token'] != null) {
            setToken(data['token']);
          }
          return data;
        } else {
          // Response was 200/201 but success=false
          print('⚠️ Got 200/201 but success=false');
          throw Exception(data['error'] ?? 'Registration failed');
        }
      } else {
        // Error codes: 4xx or 5xx
        print('❌ Registration failed with status: ${response.statusCode}');
        final errorMessage =
            data['error'] ?? data['message'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // ==================== CHURCH ENDPOINTS ====================

  static Future<List<Church>> getChurches() async {
    try {
      print('🏛️ Fetching churches from: $baseUrl/churches');

      final response = await http.get(
        Uri.parse('$baseUrl/churches'),
        headers: _headers,
      );

      print('📥 Churches response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List churches = data['data'];
        print('✅ Loaded ${churches.length} churches');
        return churches.map((json) => Church.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load churches: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading churches: $e');
      throw Exception('Error loading churches: $e');
    }
  }

  static Future<Church> getChurchById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/churches/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Church.fromJson(data['data']);
      }
      throw Exception('Failed to load church: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading church: $e');
    }
  }

  static Future<List<Service>> getServicesByChurch(int churchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/churches/$churchId/services'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List services = data['data'];
        return services.map((json) => Service.fromJson(json)).toList();
      }
      throw Exception('Failed to load services: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading services: $e');
    }
  }

  // ==================== BOOKING ENDPOINTS ====================

  static Future<List<Booking>> getBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List bookings = data['data'];
        return bookings.map((json) => Booking.fromJson(json)).toList();
      }
      throw Exception('Failed to load bookings: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading bookings: $e');
    }
  }

  static Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: _headers,
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create booking: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus(
    int id,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$id/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update booking: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  // ==================== EVENT ENDPOINTS ====================

  static Future<List<Event>> getEvents({int? priestId, int? churchId}) async {
    try {
      var url = '$baseUrl/events';
      final params = <String, String>{};

      if (priestId != null) {
        params['priest_id'] = priestId.toString();
      }
      if (churchId != null) {
        params['church_id'] = churchId.toString();
      }

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List events = data['data'];
        return events.map((json) => Event.fromJson(json)).toList();
      }
      throw Exception('Failed to load events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading events: $e');
    }
  }

  static Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> eventData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: _headers,
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  static Future<Map<String, dynamic>> updateEvent(
    int id,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$id'),
        headers: _headers,
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to delete event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  // ==================== USER ENDPOINTS ====================

  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List users = data['data'];
        return users.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  // ==================== COMPLAINT ENDPOINTS ====================

  static Future<List<Complaint>> getComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List complaints = data['data'];
        return complaints.map((json) => Complaint.fromJson(json)).toList();
      }
      throw Exception('Failed to load complaints: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading complaints: $e');
    }
  }

  static Future<Map<String, dynamic>> createComplaint(
    Map<String, dynamic> complaintData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: _headers,
        body: jsonEncode(complaintData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create complaint: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating complaint: $e');
    }
  }

  // ==================== TRANSACTION ENDPOINTS ====================

  static Future<List<Transaction>> getTransactions({
    int? churchId,
    int? methodId,
    int? statusId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      var url = '$baseUrl/transactions';
      final params = <String, String>{};

      if (churchId != null) params['church_id'] = churchId.toString();
      if (methodId != null) params['method_id'] = methodId.toString();
      if (statusId != null) params['status_id'] = statusId.toString();
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List transactions = data['data'];
        return transactions.map((json) => Transaction.fromJson(json)).toList();
      }
      throw Exception('Failed to load transactions: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }

  static Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: jsonEncode(transactionData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create transaction: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  static Future<List<Transaction>> getPendingReviews({int? churchId}) async {
    try {
      var url = '$baseUrl/transactions/pending-reviews';
      if (churchId != null) {
        url += '?church_id=$churchId';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List transactions = data['data'];
        return transactions.map((json) => Transaction.fromJson(json)).toList();
      }
      throw Exception('Failed to load pending reviews: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading pending reviews: $e');
    }
  }

  // ==================== NOTIFICATION ENDPOINTS ====================

  static Future<List<Notification>> getUserNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notifications = data['data'];
        return notifications
            .map((json) => Notification.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load notifications: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  static Future<Map<String, dynamic>> sendNotification(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers,
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to send notification: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  static Future<Map<String, dynamic>> markNotificationDelivered(
    int notificationId,
    int userId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/delivered'),
        headers: _headers,
        body: jsonEncode({
          'notification_id': notificationId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to mark as delivered: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error marking as delivered: $e');
    }
  }
}
