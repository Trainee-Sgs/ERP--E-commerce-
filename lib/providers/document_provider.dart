import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage.dart';

class DocumentItem {
  final String id;
  final String name;
  final String category;
  final String fileUrl;
  final String fileSize;
  final String uploadDate;

  DocumentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadDate,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id:         json['id']?.toString()         ?? '',
      name:       json['document_name']?.toString() ?? json['name']?.toString() ?? '',
      category:   json['category']?.toString()   ?? '',
      fileUrl:    json['file_url']?.toString()    ?? '',
      fileSize:   json['file_size']?.toString()   ?? '',
      uploadDate: json['upload_date']?.toString() ?? '',
    );
  }
}

class DocumentProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  bool   _isLoading    = false;
  String _errorMessage = '';

  bool   get isLoading    => _isLoading;
  String get errorMessage => _errorMessage;

  List<DocumentItem> _documents = [];
  List<DocumentItem> get documents => _documents;

  Future<void> fetchDocuments() async {
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
          'form':      'sm_main_form_99999',
          'select':    '*',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('DocumentProvider => Response: ${response.body}');
        }

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          for (final key in ['data', 'documents', 'records', 'result', 'list']) {
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

        _documents = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => DocumentItem.fromJson(e))
            .toList();

        debugPrint('DocumentProvider => Loaded ${_documents.length} documents');
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('DocumentProvider => Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addLocalDocument(DocumentItem doc) {
    _documents.insert(0, doc);
    notifyListeners();
  }

  void uploadDocument() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Implement actual upload logic if needed

    _isLoading = false;
    notifyListeners();
  }
}
