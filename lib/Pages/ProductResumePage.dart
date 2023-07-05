import 'package:flutter/material.dart';
import 'package:super_restaurants/model/ProductResume.dart';

import '../model/Product.dart';
import '../util/dbHelper.dart';



class StoredProductListPage extends StatefulWidget {
  @override
  _StoredProductListPageState createState() => _StoredProductListPageState();
}

class _StoredProductListPageState extends State<StoredProductListPage> {
  late List<Product> _storedProducts;
  late ProductResume _productStats;

  @override
  void initState() {
    super.initState();
    _storedProducts = [];
    _productStats = ProductResume(totalPrice: 0.0, totalStock: 0);
    fetchStoredProducts();
    fetchProductStats();
  }

  Future<void> fetchStoredProducts() async {
    final dbHelper = DatabaseHelper();
    final products = await dbHelper.getProducts();
    setState(() {
      _storedProducts = products;
    });
  }

  Future<void> fetchProductStats() async {
    final dbHelper = DatabaseHelper();
    final stats = await dbHelper.getProductStats();
    setState(() {
      _productStats = stats;
    });
  }

  Future<void> removeFromDatabase(int productId) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteProduct(productId);
    await fetchStoredProducts();
    await fetchProductStats();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text('Stored Product List'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ProductStatsModal(stats: _productStats),
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _storedProducts.length,
        itemBuilder: (context, index) {
          final product = _storedProducts[index];
          return ListTile(
            leading: Container(
              width: 100.0,
              height: 100.0,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder_image.png',
                image: product.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(product.title),
            subtitle: Text('Price: \$${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => removeFromDatabase(product.id),
            ),
          );
        },
      ),
    );
  }
}

class ProductStatsPage extends StatelessWidget {
  final ProductResume stats;

  final DatabaseHelper dbHelper = DatabaseHelper();

  ProductStatsPage({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Resumen de Productos'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<ProductResume>(
            future: dbHelper.getProductStats(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final stats = snapshot.data!;
                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio Total: \$${stats.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Stock Total: ${stats.totalStock}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}

class ProductStatsModal extends StatelessWidget {
  final ProductResume stats;
  final DatabaseHelper dbHelper = DatabaseHelper();

  ProductStatsModal({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<ProductResume>(
          future: dbHelper.getProductStats(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stats = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Price: \$${stats.totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8.0),
                  Text('Total Stock: ${stats.totalStock}'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}