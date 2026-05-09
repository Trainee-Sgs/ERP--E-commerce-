import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class PriceItem {
  final String id;
  final String productId;
  final String productName;
  final String unit;
  final String mrp;
  final String salePrice;
  final String status;
  final String createdAt;

  PriceItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.mrp,
    required this.salePrice,
    required this.status,
    required this.createdAt,
  });

  factory PriceItem.fromJson(Map<String, dynamic> json) {
    return PriceItem(
      id:          json['id']?.toString()           ?? '',
      productId:   json['product_id']?.toString()   ?? '',
      productName: json['product_name']?.toString() ?? '',
      unit:        json['unit']?.toString()         ?? '',
      mrp:         json['mrp']?.toString()          ?? '0.00',
      salePrice:   json['sale_price']?.toString()   ?? '0.00',
      status:      json['status']?.toString()       ?? '',
      createdAt:   json['created_at']?.toString()    ?? '',
    );
  }
}

class PriceProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<PriceItem> _prices = [];
  List<PriceItem> get prices => _prices;

  Future<void> fetchPrices() async {
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
          'form':      'sm_main_form_-80060',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('PriceProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'prices', 'records', 'result', 'list']) {
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

        _prices = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => PriceItem.fromJson(e))
            .toList();

        debugPrint('PriceProvider => Loaded ${_prices.length} prices');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load prices: $e';
      debugPrint('PriceProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
