import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class EcomProductItem {
  final String id;
  final String category;
  final String stockSaleType;
  final String brandName;
  final String gst;
  final String name;
  final String expireDate;
  final String subCategory;
  final String returnDate;
  final String size;
  final String uom;
  final String code;
  final String hsnCode;
  final String description;
  final String upcoming;

  EcomProductItem({
    required this.id,
    required this.category,
    required this.stockSaleType,
    required this.brandName,
    required this.gst,
    required this.name,
    required this.expireDate,
    required this.subCategory,
    required this.returnDate,
    required this.size,
    required this.uom,
    required this.code,
    required this.hsnCode,
    required this.description,
    required this.upcoming,
  });

  factory EcomProductItem.fromJson(Map<String, dynamic> json) {
    return EcomProductItem(
      id:            json['id']?.toString()            ?? '',
      category:      json['category']?.toString()      ?? '',
      stockSaleType: json['stock_sale_type']?.toString() ?? '',
      brandName:     json['brand_name']?.toString()    ?? '',
      gst:           json['gst']?.toString()           ?? '',
      name:          json['name']?.toString()          ?? '',
      expireDate:    json['expire_date']?.toString()   ?? '',
      subCategory:   json['sub_category']?.toString()  ?? '',
      returnDate:    json['return_date']?.toString()   ?? '',
      size:          json['size']?.toString()          ?? '',
      uom:           json['uom']?.toString()           ?? '',
      code:          json['code']?.toString()          ?? '',
      hsnCode:       json['hsn_sac_code']?.toString()  ?? '',
      description:   json['decrptn']?.toString()       ?? '',
      upcoming:      json['up_coming']?.toString()     ?? '',
    );
  }
}

class EcomProductProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<EcomProductItem> _items = [];
  List<EcomProductItem> get items => _items;

  Future<void> fetchEcomProducts() async {
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
          'form':      'sm_main_form_80001',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('EcomProductProvider => Response: ${response.body}');
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

        _items = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => EcomProductItem.fromJson(e))
            .toList();

        debugPrint('EcomProductProvider => Loaded ${_items.length} items');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      debugPrint('EcomProductProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
