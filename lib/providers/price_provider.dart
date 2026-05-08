import 'package:flutter/material.dart';

class PriceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _prices = [];
  List<dynamic> get prices => _prices;

  void fetchPrices() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch prices

    _isLoading = false;
    notifyListeners();
  }
}
