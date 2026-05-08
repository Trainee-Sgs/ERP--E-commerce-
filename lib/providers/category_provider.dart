import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  void fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch categories

    _isLoading = false;
    notifyListeners();
  }
}
