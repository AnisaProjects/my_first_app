import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Order {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final List<CartItem> items;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map, String docId) {
    return Order(
      id: docId,
      status: map['status'] ?? 'Pending',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() 
          [],
    );
  }
}
