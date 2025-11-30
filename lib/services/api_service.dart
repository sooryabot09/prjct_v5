// lib/services/api_service.dart - COMPLETE VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  // IMPORTANT: Update this for your environment
  // Android Emulator: 'http://10.0.2.2:3000/api'
  // iOS Simulator: 'http://localhost:3000/api'
  // Physical Device: 'http://YOUR_IP:3000/api'
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static String? _token;

  static void setToken(String token) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          setToken(data['token']);
        }
        return data;
      }
      throw Exception('Failed to login: ${response.statusCode}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          setToken(data['token']);
        }
        return data;
      }
      throw Exception('Failed to register: ${response.statusCode}');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // ==================== CHURCH ENDPOINTS ====================

  static Future<List<Church>> getChurches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/churches'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List churches = data['data'];
        return churches.map((json) => Church.fromJson(json)).toList();
      }
      throw Exception('Failed to load churches: ${response.statusCode}');
    } catch (e) {
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
}
