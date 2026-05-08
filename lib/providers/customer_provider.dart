import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _customers = [];
  List<dynamic> get customers => _customers;

  void fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch customers

    _isLoading = false;
    notifyListeners();
  }
}
