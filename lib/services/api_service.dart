import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/booking.dart';

class ApiService {
  static const String baseUrl =
      'https://6a8e2e9cbaf2ac84246da04c.mockapi.io';

  // =========================
  // BOOKINGS
  // =========================

  static Future<List<Booking>> getBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load bookings: ${response.statusCode}',
      );
    }
  }

  // =========================
  // MEDICAL REPORTS
  // =========================

  static Future<List<dynamic>> getReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Reports'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load reports: ${response.statusCode}',
      );
    }
  }
}