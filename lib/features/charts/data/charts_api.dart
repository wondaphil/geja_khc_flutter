import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';

enum ChartKind {
  byGender,          // የአባላት ብዛት በፆታ
  byMidib,           // የአባላት ብዛት በምድብ
  byEducationLevel,  // በትምህርት ደረጃ
  byMaritalStatus,   // በጋብቻ ሁኔታ
  byMembershipMeans, // በአባልነት መንገድ
  byMembershipYear,  // በአባልነት ዘመን
  bySubcity,         // በክፍለ ከተማ
}

class ChartsApi {
  final Dio _dio;
  ChartsApi({Dio? dio}) : _dio = dio ?? makeDio();

  Never _throw(DioException e) {
    final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    throw Exception('DioException ${e.response?.statusCode}: $msg');
  }

  /// Returns list of {label, count} entries suitable for pie/bar charts.
  Future<List<Map<String, dynamic>>> getData(ChartKind kind) async {
    switch (kind) {
      case ChartKind.byGender:
        // Use /GetGenderByMidib and aggregate male/female across rows.
        try {
          final res = await _dio.post(ApiPaths.getGenderByMidib);
          final rows = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();

          int male = 0, female = 0;
          for (final r in rows) {
            male += (r['male'] ?? 0) as int;
            female += (r['female'] ?? 0) as int;
          }
          return [
            {'label': 'ወንድ', 'count': male},
            {'label': 'ሴት', 'count': female},
          ];
        } on DioException catch (e) {
          _throw(e);
        }

      case ChartKind.byMidib:
        // Use any “ByMidib” endpoint that returns total per midib (GenderByMidib has total).
        try {
          final res = await _dio.post(ApiPaths.getGenderByMidib);
          final rows = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
          return rows.map((r) => {
            'label': r['midibName']?.toString() ?? '',
            'count': (r['total'] ?? 0) as int,
          }).toList();
        } on DioException catch (e) {
          _throw(e);
        }

      case ChartKind.byEducationLevel:
        // Use /GetEducationLevelByMidib: sum across midibs per education column.
        return _sumColumns(ApiPaths.getEducationLevelByMidib);

      case ChartKind.byMaritalStatus:
        return _sumColumns(ApiPaths.getMaritalStatusByMidib);

      case ChartKind.byMembershipMeans:
        return _sumColumns(ApiPaths.getMembershipMeansByMidib);

      case ChartKind.bySubcity:
        return _sumColumns(ApiPaths.getSubcityByMidib);

      case ChartKind.byMembershipYear:
        // Use GetAllMembers and group by MembershipYear
        try {
          final res = await _dio.post(ApiPaths.getAllMembers);
          final list = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
          final Map<String, int> buckets = {};
          for (final m in list) {
            final y = m['MembershipYear'] ?? m['membershipYear'];
            final key = (y == null || y.toString().trim().isEmpty) ? 'ያልተገለጸ' : y.toString();
            buckets[key] = (buckets[key] ?? 0) + 1;
          }
          final entries = buckets.entries.toList()
            ..sort((a, b) {
              int ai = int.tryParse(a.key) ?? -1;
              int bi = int.tryParse(b.key) ?? -1;
              return ai.compareTo(bi);
            });
          return entries.map((e) => {'label': e.key, 'count': e.value}).toList();
        } on DioException catch (e) {
          _throw(e);
        }
    }
  }

  /// Helper: endpoints like GetEducationLevelByMidib return rows per midib:
  /// { midibName, total?, colA, colB, ... }. We sum all non-tech columns across rows.
  Future<List<Map<String, dynamic>>> _sumColumns(String path) async {
    try {
      final res = await _dio.post(path);
      final rows = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      if (rows.isEmpty) return const [];

      final tech = {'rowId', 'midibId', 'midibName', 'total'};
      final sums = <String, int>{};
      for (final r in rows) {
        r.forEach((k, v) {
          if (tech.contains(k)) return;
          if (v is int) {
            sums[k] = (sums[k] ?? 0) + v;
          }
        });
      }
      // Pretty labels if you later want; for now use keys as-is
      return sums.entries
          .where((e) => e.value > 0)
          .map((e) => {'label': e.key.toString(), 'count': e.value})
          .toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }
}