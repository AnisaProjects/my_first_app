import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String _errorMessage = '';

  int _totalProducts = 0;
  int _lowStockProducts = 0;
  String _apiStatusText = '';

  // =====================
  // GETTERS
  // =====================

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get totalProducts => _totalProducts;
  int get lowStockProducts => _lowStockProducts;
  String get apiStatusText => _apiStatusText;

  // =====================
  // LOAD DASHBOARD
  // =====================

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _loadFromFirestore();
      await _loadFromDummyApi();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard';
      debugPrint('Dashboard load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================
  // FIRESTORE DATA
  // =====================

  Future<void> _loadFromFirestore() async {
    final snapshot = await _firestore.collection('products').get();

    final products = snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();

    _totalProducts = products.length;

    // Low stock defined as <= 5
    _lowStockProducts = products.where((p) => p.stock <= 5).length;
  }

  // =====================
  // REAL API (dummyjson.com)
  // =====================

  Future<void> _loadFromDummyApi() async {
    try {
      final url = Uri.parse('https://dummyjson.com/products?limit=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final totalRemote = data['total'] as int;
        _apiStatusText = 'API Status: OK (Found $totalRemote remote products)';
      } else {
        _apiStatusText = 'API Status: Error ${response.statusCode}';
      }
    } catch (e) {
      _apiStatusText = 'API Status: Failed to connect';
      debugPrint('API Error: $e');
    }
  }
}
