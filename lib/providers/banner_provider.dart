import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class BannerItem {
  final String id;
  final String name;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final String status;

  BannerItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.status = '',
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id:        json['id']?.toString()         ?? '',
      name:      json['Banner_Name']?.toString() ?? json['banner_name']?.toString() ?? json['name']?.toString() ?? '',
      imageUrl:  json['Banner_Image']?.toString() ?? json['banner_image']?.toString() ?? json['image']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate:   json['end_date']?.toString()   ?? '',
      status:    json['status']?.toString()     ?? '',
    );
  }
}

class BannerProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<BannerItem> _banners = [];
  List<BannerItem> get banners => _banners;

  Future<void> fetchBanners() async {
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
          'lt':        lat.isNotEmpty      ? lat      : '123',
          'ln':        lng.isNotEmpty      ? lng      : '123',
          'device_id': deviceId.isNotEmpty ? deviceId : '123',
          'uid':       uid.isNotEmpty      ? uid      : '123',
          'role_id':   roleId.isNotEmpty   ? roleId   : '123',
          'form':      'sm_main_form_80101',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('BannerProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'banners', 'records', 'result', 'list']) {
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

        _banners = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => BannerItem.fromJson(e))
            .toList();

        debugPrint('BannerProvider => Loaded ${_banners.length} banners');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load banners: $e';
      debugPrint('BannerProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
