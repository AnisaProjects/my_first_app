import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/myorder.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// FETCH ORDERS FOR CURRENT USER
  Future<void> fetchOrdersForCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _ordersSubscription?.cancel();

      _ordersSubscription = _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
            if (kDebugMode) {
              print("👤 UID: ${user.uid}");
              print("📦 Orders found: ${snapshot.docs.length}");
            }

            _orders = snapshot.docs.map((doc) {
              return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();

            _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            _isLoading = false;
            notifyListeners();
          });
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CREATE ORDER
  Future<void> createOrder(List<CartItem> cartItems, double total) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final timestamp = Timestamp.now();

    final itemsData = cartItems.map((item) => item.toMap()).toList();

    final orderData = {
      'userId': user.uid,
      'totalAmount': total,
      'status': 'pending',
      'createdAt': timestamp,
      'items': itemsData,
    };

    await _firestore.collection('orders').add(orderData);
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  int get totalOrders => _orders.length;
}
