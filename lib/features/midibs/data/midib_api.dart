import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import 'midib.dart';

class MidibApi {
  final Dio _dio;
  MidibApi({Dio? dio}) : _dio = dio ?? makeDio();

  Never _throw(DioException e) {
    final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    throw Exception('DioException ${e.response?.statusCode}: $msg');
  }

  /// GET list of Midibs
  /// Server route: /api/GejaKhcAPI/GetMidibList (expects POST with no body)
  Future<List<Midib>> listMidibs() async {
    try {
      final res = await _dio.post(ApiPaths.listMidibs);
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Midib.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Get a single Midib by id.
  /// Some endpoints require multiple casings/aliases; include them all.
  Future<Midib> getMidib(String id) async {
    try {
      final body = {
        'Id': id, 'id': id, 'MidibId': id, 'midibId': id,
      };
      final res = await _dio.post(ApiPaths.getMidib, data: body);
      return Midib.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Fetch Midib for edit (fail-safe: include required fields that
  /// your API model binder validates: name + midibCode).
  Future<Midib> getMidibForEdit({
    required String id,
    required String name,
    required String midibCode,
  }) async {
    try {
      final body = {
        // IDs
        'Id': id, 'id': id, 'MidibId': id, 'midibId': id,
        // Required props
        'Name': name, 'name': name,
        'MidibCode': midibCode, 'midibCode': midibCode,
        // Some actions validate a 'Midib' string too
        'Midib': midibCode, 'midib': midibCode,
      };
      final res = await _dio.post(ApiPaths.getMidib, data: body);
      return Midib.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Create or update a Midib.
  /// Server route (per your CSV): SetMidib
  Future<void> setMidib(Midib m) async {
    try {
      final body = {
        // IDs (send all common casings)
        'Id': m.id, 'id': m.id, 'MidibId': m.id, 'midibId': m.id,
        // Required fields
        'Name': m.name, 'name': m.name,
        'MidibCode': m.midibCode, 'midibCode': m.midibCode,
        // Some backends also look for this key
        'Midib': m.midibCode, 'midib': m.midibCode,
        // Optional
        'Pastor': m.pastor, 'pastor': m.pastor,
        'Remark': m.remark, 'remark': m.remark,
      };
      await _dio.post(ApiPaths.setMidib, data: body);
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Server route: DeleteMidib
  Future<void> deleteMidib({
	  required String id,
	  String? name,
	  String? midibCode,
	}) async {
	  try {
		final body = {
		  // ids (many casings)
		  'Id': id, 'id': id, 'MidibId': id, 'midibId': id,
		  // helpful for model binders that validate DTOs
		  'Name': name ?? '', 'name': name ?? '',
		  'MidibCode': midibCode ?? '', 'midibCode': midibCode ?? '',
		  'Midib': midibCode ?? name ?? '', 'midib': midibCode ?? name ?? '',
		};
		await _dio.post(ApiPaths.deleteMidib, data: body);
	  } on DioException catch (e) {
		_throw(e);
	  }
	}

}
