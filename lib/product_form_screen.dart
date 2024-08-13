import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _thumbnailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!['title'];
      _priceController.text = widget.product!['price'].toString();
      _thumbnailController.text = widget.product!['thumbnail'];
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('https://dummyjson.com/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> createProduct(Map<String, dynamic> newProductData) async {
    final response = await http.post(
      Uri.parse('https://dummyjson.com/products/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newProductData),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to create product');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final appBarTitle = isEdit ? 'Edit Product' : 'Create Product';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _thumbnailController,
              decoration: const InputDecoration(labelText: 'Thumbnail URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text;
                final price = int.tryParse(_priceController.text) ?? 0;
                final thumbnail = _thumbnailController.text;

                if (isEdit) {
                  final updatedData = {
                    'title': title,
                    'price': price,
                    'thumbnail': thumbnail,
                  };
                  await updateProduct(widget.product!['id'], updatedData);
                } else {
                  final newProductData = {
                    'title': title,
                    'price': price,
                    'thumbnail': thumbnail,
                  };
                  await createProduct(newProductData);
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
