import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class AddressItem {
  final String id;
  final String name;
  final String mobile;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String type;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.name,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.type,
    required this.isDefault,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id:           json['id']?.toString()           ?? '',
      name:         json['recipient_name']?.toString()?? json['name']?.toString() ?? '',
      mobile:       json['mobile_number']?.toString() ?? '',
      addressLine1: json['address_line_1']?.toString()?? '',
      addressLine2: json['address_line_2']?.toString()?? '',
      landmark:     json['landmark']?.toString()      ?? '',
      city:         json['city']?.toString()          ?? '',
      state:        json['state']?.toString()         ?? '',
      pincode:      json['pincode']?.toString()       ?? '',
      country:      json['country']?.toString()       ?? '',
      type:         json['address_type']?.toString()  ?? '',
      isDefault:    json['default_address']?.toString() == '1',
    );
  }
}

class AddressProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<AddressItem> _addresses = [];
  List<AddressItem> get addresses => _addresses;

  Future<void> fetchAddresses() async {
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
          'form':      'sm_main_form_80510',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('AddressProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          
          for (final key in ['data', 'addresses', 'records', 'result', 'list']) {
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

        _addresses = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => AddressItem.fromJson(e))
            .toList();

        debugPrint('AddressProvider => Loaded ${_addresses.length} addresses');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load addresses: $e';
      debugPrint('AddressProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
