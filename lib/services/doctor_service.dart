import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/doctor.dart';

class DoctorService {
  // ==============================
  // DOCTORS API
  // ==============================

  static const String doctorsUrl =
      'https://6a8ca3f163f113bab0b86201.mockapi.io/doctors';

  // ==============================
  // RECENT SEARCHES API
  // ==============================

  static const String searchesUrl =
      'https://6a8ca3f163f113bab0b86201.mockapi.io/recent-searches';

  // ==============================
  // REVIEWS API
  // ==============================

  static const String reviewsUrl =
      'https://6a8de377baf2ac84246d837d.mockapi.io/reviews';

  // ==============================
  // GET DOCTORS
  // ==============================

  static Future<List<Doctor>> getDoctors() async {
    final response = await http.get(
      Uri.parse(doctorsUrl),
    );

    debugPrint('GET DOCTORS STATUS: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Doctor.fromJson(json)).toList();
    }

    throw Exception('Failed to load doctors');
  }

  // ==============================
  // GET RECENT SEARCHES
  // ==============================

  static Future<List<dynamic>> getRecentSearches() async {
    final response = await http.get(
      Uri.parse(searchesUrl),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load recent searches');
  }

  // ==============================
  // UPDATE FAVORITE
  // ==============================

  static Future<void> updateFavorite(
    String id,
    bool isFavorite,
  ) async {
    if (id == 'null' || id.isEmpty) {
      throw Exception('Doctor ID is missing');
    }

    final url = '$doctorsUrl/$id';

    debugPrint('UPDATE FAVORITE URL: $url');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'isFavorite': isFavorite,
      }),
    );

    debugPrint(
      'STATUS CODE: ${response.statusCode}',
    );

    debugPrint(
      'RESPONSE: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update favorite',
      );
    }
  }

  // ==============================
  // GET REVIEWS
  // ==============================

  static Future<List<dynamic>> getReviews(
    String doctorId,
  ) async {
    final response = await http.get(
      Uri.parse(reviewsUrl),
    );

    if (response.statusCode == 200) {
      final List<dynamic> allReviews =
          jsonDecode(response.body);

      return allReviews.where((review) {
        return review['doctorId']?.toString() == doctorId;
      }).toList();
    }

    throw Exception('Failed to load reviews');
  }

  // ==============================
  // ADD REVIEW
  // ==============================

  static Future<void> addReview({
    required String doctorId,
    required String patientName,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse(reviewsUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'patientName': patientName,
        'patientAvatar': '',
        'rating': rating,
        'comment': comment,
        'date': 'Just now',
        'doctorId': doctorId,
        'helpful': false,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to add review');
    }
  }
}