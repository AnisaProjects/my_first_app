class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imagePath; // local image path (image_picker)

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imagePath,
  });

  /// Create Product object from Firestore document
  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      imagePath: data['imagePath'] as String?,
    );
  }

  /// Convert Product object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
    };
  }

  /// Copy Product with updated values (useful for update)
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
