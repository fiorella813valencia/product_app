import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:super_restaurants/model/ProductResume.dart';

import '../model/Product.dart';
import '../util/dbHelper.dart';
import 'ProductResumePage.dart';


class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late List<Product> _products;
  late ProductResume _productStats;

  @override
  void initState() {
    super.initState();
    _products = [];
    _productStats = ProductResume(totalPrice: 0.0, totalStock: 0);
    fetchProducts();
    fetchProductStats();
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final productsData = jsonData['products'] as List<dynamic>;
      final products = productsData.map((item) => Product.fromJson(item)).toList();
      setState(() {
        _products = products;
      });
      return products; // Agregar la declaración de retorno aquí
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<void> fetchProductStats() async {
    final dbHelper = DatabaseHelper();
    final stats = await dbHelper.getProductStats();
    setState(() {
      _productStats = stats;
    });
  }

  Future<void> addToDatabase(Product product) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertProduct(product);
    await fetchProductStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
          backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductStatsPage(stats: _productStats)),
              );
            },
            icon: const Icon(Icons.monetization_on),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoredProductListPage()),
              );
            },
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: Container(
              width: 100,
              height: 100,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(product.title),
            subtitle: Text('Price: \$${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: () => addToDatabase(product),
            ),
          );
        },
      ),
    );
  }
}