import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _name;
  String? _role = 'Store Manager';
  String? _status = 'Active';
  bool _isLoading = false;

  String get name => _name ?? (_auth.currentUser?.displayName) ?? 'User';
  String get role => _role ?? 'Store Manager';
  String get status => _status ?? 'Active';
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? user.displayName;
        _role = data['role'] ?? 'Store Manager';
        _status = data['status'] ?? 'Active';
      } else {
        // Initialize profile in Firestore if missing
        _name = user.displayName;
        await _saveProfileRaw(user.uid, {
          'name': _name ?? 'User',
          'email': user.email,
          'role': _role,
          'status': _status,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Update Auth
      await user.updateDisplayName(newName);
      await user.reload();

      // Update Firestore
      await _saveProfileRaw(user.uid, {'name': newName});
      
      _name = newName;
    } catch (e) {
      if (kDebugMode) print('Error updating name: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveProfileRaw(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
}
