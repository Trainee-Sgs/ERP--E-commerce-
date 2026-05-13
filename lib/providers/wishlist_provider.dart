import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class WishlistItem {
  final String id;
  final String wishlistId;
  final String customerId;
  final String productId;
  final String productName;
  final String productImage;
  final String unitSize;
  final String quantity;
  final String price;
  final String rating;
  final String category;
  final String addedDate;

  WishlistItem({
    required this.id,
    required this.wishlistId,
    required this.customerId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.unitSize,
    required this.quantity,
    required this.price,
    required this.rating,
    required this.category,
    required this.addedDate,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id:            json['id']?.toString()            ?? '',
      wishlistId:    json['wishlist_id']?.toString()   ?? '',
      customerId:    json['customer_id']?.toString()   ?? '',
      productId:     json['product_id']?.toString()    ?? '',
      productName:   json['product_name']?.toString()  ?? '',
      productImage:  json['product_image']?.toString() ?? '',
      unitSize:      json['unit_size']?.toString()     ?? '',
      quantity:      json['quantity']?.toString()      ?? '0',
      price:         json['price']?.toString()         ?? '0.00',
      rating:        json['rating']?.toString()        ?? '0.0',
      category:      json['category']?.toString()      ?? '',
      addedDate:     json['added_date']?.toString()    ?? '',
    );
  }
}

class WishlistProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<WishlistItem> _items = [];
  List<WishlistItem> get items => _items;

  Future<void> fetchWishlist() async {
    _isLoading    = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final cid      = await LocalStorage.getCid();
      final lat      = await LocalStorage.getLat();
      final lng      = await LocalStorage.getLng();
      final deviceId = await LocalStorage.getDeviceId();
      final uid      = await LocalStorage.getUid();
      final roleId   = await LocalStorage.getRoleId();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type':      '2083',
          'cid':       cid.isNotEmpty      ? cid      : '44555666',
          'lt':        lat.isNotEmpty      ? lat      : '123',
          'ln':        lng.isNotEmpty      ? lng      : '123',
          'device_id': deviceId.isNotEmpty ? deviceId : '123',
          'uid':       uid.isNotEmpty      ? uid      : '123',
          'role_id':   roleId.isNotEmpty   ? roleId   : '123',
          'form':      'sm_main_form_80530',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('WishlistProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'items', 'records', 'result', 'list']) {
            if (decoded.containsKey(key) && decoded[key] is List) {
              rawList = decoded[key] as List<dynamic>;
              break;
            }
          }
          if (rawList.isEmpty) {
            for (final value in decoded.values) {
              if (value is List && value.isNotEmpty) {
                rawList = value;
                break;
              }
            }
          }
        }

        _items = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => WishlistItem.fromJson(e))
            .toList();

        debugPrint('WishlistProvider => Loaded ${_items.length} items');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load wishlist: $e';
      debugPrint('WishlistProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
