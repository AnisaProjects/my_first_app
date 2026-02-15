
import 'package:flutter/foundation.dart';
import 'product.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final String? imagePath;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    this.imagePath,
  });

  double get totalAmount => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    double? price,
    String? category,
    String? imagePath,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId, // Important: Store productId for reference
      'name': name,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'category': category,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? DateTime.now().toString(), // Should ideally store ID
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}
