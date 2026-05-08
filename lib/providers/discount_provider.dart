import 'package:flutter/material.dart';

class DiscountProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _discounts = [];
  List<dynamic> get discounts => _discounts;

  void fetchDiscounts() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch discounts

    _isLoading = false;
    notifyListeners();
  }
}
