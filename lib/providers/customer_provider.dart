import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class CustomerItem {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String profileImage;
  final String status;
  final String createdAt;
  final String updatedAt;

  CustomerItem({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profileImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerItem.fromJson(Map<String, dynamic> json) {
    return CustomerItem(
      id:           json['id']?.toString()           ?? '',
      name:         json['customer_name']?.toString() ?? json['name']?.toString() ?? '',
      email:        json['email']?.toString()        ?? '',
      mobile:       json['mobile_number']?.toString() ?? json['mobile']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      status:       json['status']?.toString()       ?? '',
      createdAt:    json['created_at']?.toString()    ?? '',
      updatedAt:    json['updated_at']?.toString()    ?? '',
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<CustomerItem> _customers = [];
  List<CustomerItem> get customers => _customers;

  Future<void> fetchCustomers() async {
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
          'form':      'sm_main_form_80500',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('CustomerProvider => Response: ${response.body}');
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
            .map((e) => CustomerItem.fromJson(e))
            .toList();

        debugPrint('CustomerProvider => Loaded ${_customers.length} customers');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load customers: $e';
      debugPrint('CustomerProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
