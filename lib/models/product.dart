class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imagePath,
  });

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
    };
  }

  // Copy Product with optional changes
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

  // Create Product from Firestore Map
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      imagePath: map['imagePath'],
    );
  }
}
