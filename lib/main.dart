import 'package:flutter/material.dart';

import 'Pages/ProductList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Soft Route App",
      debugShowCheckedModeBanner: false,
      home:ProductListPage(),
    );
  }
}