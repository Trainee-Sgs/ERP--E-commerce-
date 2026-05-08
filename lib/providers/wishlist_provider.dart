import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _wishlistItems = [];
  List<dynamic> get wishlistItems => _wishlistItems;

  void fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Bind API to fetch wishlist items

    _isLoading = false;
    notifyListeners();
  }
}
