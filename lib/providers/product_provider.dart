import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Product> get products {
    if (_searchQuery.isEmpty) return [..._products];
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Create products collection if it doesn't exist (implicitly by adding, but here we just read)
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch products: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new product
  Future<void> addProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = Product(
        id: '', // ID will be assigned by Firestore
        name: name,
        category: category,
        price: price,
        stock: stock,
        imagePath: imagePath,
      );

      final docRef = await _firestore.collection('products').add(newProduct.toMap());
      
      // Update local list with the new product including the generated ID
      final productWithId = newProduct.copyWith(id: docRef.id);
      _products.add(productWithId);
      
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      debugPrint(_errorMessage);
      rethrow; // Re-throw to allow UI to handle success/failure logic if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing product
  Future<void> updateProduct({
    required String id,
    required String name,
    required String category,
    required double price,
    required int stock,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = Product(
        id: id,
        name: name,
        category: category,
        price: price,
        stock: stock,
        imagePath: imagePath,
      );

      await _firestore.collection('products').doc(id).update(updatedProduct.toMap());

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
