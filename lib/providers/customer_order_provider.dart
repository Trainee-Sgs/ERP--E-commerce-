import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class CustomerOrderItem {
  final String id;
  final String orderId;
  final String customerName;
  final String amount;
  final String orderDate;
  final String status;
  final String createdAt;

  CustomerOrderItem({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.orderDate,
    required this.status,
    required this.createdAt,
  });

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    return CustomerOrderItem(
      id:           json['id']?.toString()           ?? '',
      orderId:      json['order_id']?.toString()      ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      amount:       json['total_amount']?.toString()  ?? json['amount']?.toString() ?? '0.00',
      orderDate:    json['order_date']?.toString()    ?? '',
      status:       json['status']?.toString()       ?? '',
      createdAt:    json['created_at']?.toString()    ?? '',
    );
  }
}

class CustomerOrderProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<CustomerOrderItem> _orders = [];
  List<CustomerOrderItem> get orders => _orders;

  Future<void> fetchCustomerOrders() async {
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
          'form':      'sm_main_form_-80520',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('CustomerOrderProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'orders', 'records', 'result', 'list']) {
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

        _orders = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerOrderItem.fromJson(e))
            .toList();

        debugPrint('CustomerOrderProvider => Loaded ${_orders.length} orders');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      debugPrint('CustomerOrderProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
