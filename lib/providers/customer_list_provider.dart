import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class CustomerListItem {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String installDate;
  final String renewalDate;
  final String status;

  CustomerListItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.installDate,
    required this.renewalDate,
    required this.status,
  });

  factory CustomerListItem.fromJson(Map<String, dynamic> json) {
    return CustomerListItem(
      id:          json['id']?.toString()          ?? '',
      name:        json['customer_name']?.toString()?? json['name']?.toString() ?? '',
      phone:       json['phone_number']?.toString() ?? json['mobile']?.toString() ?? '',
      email:       json['email']?.toString()       ?? '',
      address:     json['address']?.toString()     ?? '',
      installDate: json['install_date']?.toString() ?? '',
      renewalDate: json['renewal_date']?.toString() ?? '',
      status:      json['status']?.toString()      ?? '',
    );
  }
}

class CustomerListProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<CustomerListItem> _customers = [];
  List<CustomerListItem> get customers => _customers;

  Future<void> fetchCustomerList() async {
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
          'form':      'sm_main_form_21701',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('CustomerListProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'customers', 'records', 'result', 'list']) {
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

        _customers = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerListItem.fromJson(e))
            .toList();

        debugPrint('CustomerListProvider => Loaded ${_customers.length} customers');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load customers: $e';
      debugPrint('CustomerListProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
