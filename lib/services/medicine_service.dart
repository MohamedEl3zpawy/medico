import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/medicine.dart';
import '../models/pharmacy.dart';
import '../models/offer.dart';
import '../models/order.dart';

class MedicineService {
  static const String medicinesUrl =
      'https://6a8de377baf2ac84246d837d.mockapi.io/medicines';

  static const String pharmacyUrl =
      'https://6a8e0a00baf2ac84246d93a2.mockapi.io/pharmacy';

  static const String offersUrl =
      'https://6a8e0a00baf2ac84246d93a2.mockapi.io/offers';

  static const String ordersUrl =
      'https://6a95d47afa33b37f821af6b2.mockapi.io/myorders';

  // ================= MEDICINES =================

  static Future<List<Medicine>> getMedicines() async {
    final response = await http.get(Uri.parse(medicinesUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Medicine.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  // ================= PHARMACIES =================

  static Future<List<Pharmacy>> getPharmacies() async {
    final response = await http.get(Uri.parse(pharmacyUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Pharmacy.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pharmacies');
    }
  }

  // ================= OFFERS =================

  static Future<List<Offer>> getOffers() async {
    final response = await http.get(Uri.parse(offersUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load offers');
    }
  }

  // ================= ORDERS =================

  static Future<List<MedOrder>> getOrders() async {
    final response = await http.get(Uri.parse(ordersUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedOrder.fromJson(json)).toList();
    } else {
      debugPrint('Orders API Error: ${response.statusCode}');
      throw Exception('Failed to load orders');
    }
  }

  static Future<void> createOrder(Medicine medicine) async {
    final response = await http.post(
      Uri.parse(ordersUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'medicineName': medicine.name,
        'price': medicine.price.toString(),
        'category': medicine.category,
        'image': medicine.image,
        'status': 'Ordered',
        'quantity': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'Medicine',
      }),
    );

    debugPrint('Create Order Status: ${response.statusCode}');
    debugPrint('Create Order Response: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create order');
    }
  }
}