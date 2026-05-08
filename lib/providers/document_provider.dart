import 'package:flutter/material.dart';

class DocumentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void uploadDocument() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to upload document

    _isLoading = false;
    notifyListeners();
  }
}
