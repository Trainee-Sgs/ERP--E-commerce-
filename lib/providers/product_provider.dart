import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class ProductItem {
  final String id;
  final String productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productStock;
  final String productImage;
  final String category;
  final String status;

  ProductItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productStock,
    required this.productImage,
    required this.category,
    required this.status,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id:                 json['id']?.toString()                  ?? '',
      productId:          json['product_id']?.toString()          ?? '',
      productName:        json['product_name']?.toString()        ?? '',
      productDescription: json['product_description']?.toString() ?? '',
      productPrice:       json['product_price']?.toString()       ?? '0.00',
      productStock:       json['product_stock']?.toString()       ?? '0',
      productImage:       json['product_image']?.toString()       ?? '',
      category:           json['category']?.toString()            ?? '',
      status:             json['status']?.toString()              ?? '',
    );
  }
}

class ProductProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<ProductItem> _products = [];
  List<ProductItem> get products => _products;

  Future<void> fetchProducts() async {
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
          'form':      'sm_main_form_80050',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('ProductProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'products', 'records', 'result', 'list']) {
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

        _products = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => ProductItem.fromJson(e))
            .toList();

        debugPrint('ProductProvider => Loaded ${_products.length} products');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      debugPrint('ProductProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
