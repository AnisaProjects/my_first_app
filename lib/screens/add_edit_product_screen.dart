import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _categoryController.text = p.category;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();

      if (p.imagePath != null) {
        _pickedImage = XFile(p.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    
    final productProvider = context.read<ProductProvider>();

    setState(() => _isSaving = true);

    try {
      String? imagePath = widget.product?.imagePath;

      // Upload image if picked
      if (_pickedImage != null) {
        final file = File(_pickedImage!.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}';
        final ref = FirebaseStorage.instance.ref().child('product_images').child(fileName);
        
        await ref.putFile(file);
        imagePath = await ref.getDownloadURL();
      }



      if (_isEditing) {
        await productProvider.updateProduct(
          id: widget.product!.id,
          name: name,
          category: category,
          price: price,
          stock: stock,
          imagePath: imagePath,
        );
      } else {
        await productProvider.addProduct(
          name: name,
          category: category,
          price: price,
          stock: stock,
          imagePath: imagePath,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Product' : 'Add Product';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (widget.product?.imagePath != null && widget.product!.imagePath!.startsWith('http'))
                            ? NetworkImage(widget.product!.imagePath!) as ImageProvider
                            : null,
                    child: (_pickedImage == null && widget.product?.imagePath == null)
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter product name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter category' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => double.tryParse(v ?? '') == null
                      ? 'Enter valid price'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => int.tryParse(v ?? '') == null
                      ? 'Enter valid stock'
                      : null,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _save,
                          child: Text(_isEditing ? 'Update' : 'Create'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
