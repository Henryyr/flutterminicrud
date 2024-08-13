import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen
import 'product_form_screen.dart'; // Import the form screen
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Show login screen first
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products'));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body)['products'];
        });
      } else {
        _showError('Failed to load products');
      }
    } catch (error) {
      _showError('Error fetching products');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('https://dummyjson.com/products/$id'));
      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((product) => product['id'] == id);
        });
      } else {
        _showError('Failed to delete product');
      }
    } catch (error) {
      _showError('Error deleting product');
    }
  }

  Future<void> createProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductFormScreen()),
    );
    if (result == true) {
      fetchProducts(); // Refresh the list after creation
    }
  }

  Future<void> updateProduct(Map<String, dynamic> product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
    );
    if (result == true) {
      fetchProducts(); // Refresh the list after update
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.network(
                product['thumbnail'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product['title']),
              subtitle: Text('\$${product['price']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => updateProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteProduct(product['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createProduct,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple.withOpacity(0.7),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
