import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class DiscountItem {
  final String id;
  final String date;
  final String productName;
  final String productCategory;
  final String discountType;
  final String discountValue;
  final String validFrom;
  final String validTo;
  final String status;
  final String remarks;
  final String productCode;

  DiscountItem({
    required this.id,
    required this.date,
    required this.productName,
    required this.productCategory,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    required this.status,
    required this.remarks,
    required this.productCode,
  });

  factory DiscountItem.fromJson(Map<String, dynamic> json) {
    return DiscountItem(
      id:              json['id']?.toString()               ?? '',
      date:            (json['date'] ?? json['created_at'])?.toString() ?? '',
      productName:     (json['product_name'] ?? json['discount_name'])?.toString() ?? '',
      productCategory: (json['product_category'] ?? json['category'])?.toString() ?? '',
      discountType:    json['discount_type']?.toString()    ?? '',
      discountValue:   json['discount_value']?.toString()   ?? '0.00',
      validFrom:       json['valid_from']?.toString()       ?? '',
      validTo:         json['valid_to']?.toString()         ?? '',
      status:          json['status']?.toString()           ?? '',
      remarks:         json['remarks']?.toString()          ?? '',
      productCode:     json['product_code']?.toString()     ?? '',
    );
  }
}

class DiscountProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<DiscountItem> _discounts = [];
  List<DiscountItem> get discounts => _discounts;

  Future<void> fetchDiscounts() async {
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
          'form':      'sm_main_form_80065',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('DiscountProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'discounts', 'records', 'result', 'list']) {
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

        _discounts = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => DiscountItem.fromJson(e))
            .toList();

        debugPrint('DiscountProvider => Loaded ${_discounts.length} discounts');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load discounts: $e';
      debugPrint('DiscountProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
