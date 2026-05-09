import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart'; // your SharedPreferences helper

// ─────────────────────────────────────────────
//  Order Model
// ─────────────────────────────────────────
class OrderItem {
  final String id;
  final String customer;
  final double amount;
  final String status;
  final String billingAddress;
  final String shippingAddress;
  final String shippingMethod;
  final String shippingCost;
  final String totalPrice;
  final String orderDate;
  final String cancellationDate;
  final String cancellationReason;
  final String cancelledBy;
  final String trackingNumber;
  final String paymentStatus;
  final String paymentMethod;
  final String couponCode;
  final String refundStatus;
  final String accountNumber;
  final String bankName;
  final String holderName;
  final String ifsc;

  OrderItem({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    this.billingAddress     = '',
    this.shippingAddress    = '',
    this.shippingMethod     = '',
    this.shippingCost       = '',
    this.totalPrice         = '',
    this.orderDate          = '',
    this.cancellationDate   = '',
    this.cancellationReason = '',
    this.cancelledBy        = '',
    this.trackingNumber     = '',
    this.paymentStatus      = '',
    this.paymentMethod      = '',
    this.couponCode         = '',
    this.refundStatus       = '',
    this.accountNumber      = '',
    this.bankName           = '',
    this.holderName         = '',
    this.ifsc               = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id:               json['id']?.toString()                    ?? '',
      customer:         json['customer_name']?.toString()
                     ?? json['customer']?.toString()              ?? '',
      amount:           double.tryParse(
                          json['total_price']?.toString() ?? '0') ?? 0.0,
      status:           json['order_status']?.toString()
                     ?? json['status']?.toString()                ?? '',
      billingAddress:   json['billing_address']?.toString()       ?? '',
      shippingAddress:  json['shipping_address']?.toString()      ?? '',
      shippingMethod:   json['shipping_method']?.toString()       ?? '',
      shippingCost:     json['shipping_cost']?.toString()         ?? '',
      totalPrice:       json['total_price']?.toString()           ?? '',
      orderDate:        json['order_date']?.toString()            ?? '',
      cancellationDate:   json['cancellation_date']?.toString()   ?? '',
      cancellationReason: json['cancellation_reason']?.toString() ?? '',
      cancelledBy:        json['cancelled_by']?.toString()        ?? '',
      trackingNumber:     json['tracking_number']?.toString()     ?? '',
      paymentStatus:  json['payment_status']?.toString()          ?? '',
      paymentMethod:  json['payment_method']?.toString()          ?? '',
      couponCode:     json['coupon_code']?.toString()             ?? '',
      refundStatus:   json['refund_status']?.toString()           ?? '',
      accountNumber:  json['account_number']?.toString()          ?? '',
      bankName:       json['bank_name']?.toString()               ?? '',
      holderName:     json['holder_name']?.toString()             ?? '',
      ifsc:           json['ifsc']?.toString()                    ?? '',
    );
  }
}

// ─────────────────────────────────────────────
//  OrderProvider
// ─────────────────────────────────────────────
class OrderProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  bool   _isSaving     = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  bool   get isSaving     => _isSaving;
  String get errorMessage => _errorMessage;

  List<OrderItem> _orders = [];
  List<OrderItem> get orders => _orders;

  // ── Filtered getters ──────────────────────────────────────────────────────
  List<OrderItem> get confirmedOrders =>
      _orders.where((o) => o.status.toLowerCase() == 'confirmed').toList();
  List<OrderItem> get shippedOrders =>
      _orders.where((o) => o.status.toLowerCase() == 'shipped').toList();
  List<OrderItem> get deliveredOrders =>
      _orders.where((o) => o.status.toLowerCase() == 'delivered').toList();
  List<OrderItem> get cancelledOrders =>
      _orders.where((o) => o.status.toLowerCase() == 'cancelled').toList();

  List<OrderItem> getOrdersByStatus(String status) => _orders
      .where((o) => o.status.toLowerCase() == status.toLowerCase())
      .toList();

  // ── Fetch all orders from API ─────────────────────────────────────────────
  Future<void> fetchOrders() async {
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
          'cid':       cid.isNotEmpty      ? cid      : '99994444',
          'lt':        lat.isNotEmpty       ? lat      : '123',
          'ln':        lng.isNotEmpty       ? lng      : '123',
          'device_id': deviceId.isNotEmpty  ? deviceId : '123',
          'uid':       uid.isNotEmpty       ? uid      : '123',
          'role_id':   roleId.isNotEmpty    ? roleId   : '123',
          'form':      'sm_main_form_-80520',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('OrderProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // Try common wrapper keys
          for (final key in ['data', 'orders', 'records', 'result', 'list']) {
            if (decoded.containsKey(key) && decoded[key] is List) {
              rawList = decoded[key] as List<dynamic>;
              break;
            }
          }
          // Fallback: first List value found
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
            .map((e) => OrderItem.fromJson(e))
            .toList();

        debugPrint('OrderProvider => Loaded ${_orders.length} orders');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        debugPrint('OrderProvider => HTTP ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
      debugPrint('OrderProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearOrders() {
    _orders       = [];
    _errorMessage = '';
    notifyListeners();
  }

  // ── Insert order ────────────────────────────────────────────────────────
  Future<bool> insertOrder(OrderItem order) async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate API call or insert logic here.
      // You can add proper http.post logic similar to fetchOrders.
      await Future.delayed(const Duration(seconds: 1));
      
      // On success, we can just add it to the local list for now
      _orders.insert(0, order);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save order: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}