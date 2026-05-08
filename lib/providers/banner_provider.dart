import 'package:flutter/material.dart';

class BannerProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _banners = [];
  List<dynamic> get banners => _banners;

  void fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch banner images

    _isLoading = false;
    notifyListeners();
  }
}
