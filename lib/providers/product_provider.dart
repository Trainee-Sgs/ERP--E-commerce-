import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _products = [];
  List<dynamic> get products => _products;

  void fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch products

    _isLoading = false;
    notifyListeners();
  }
}
