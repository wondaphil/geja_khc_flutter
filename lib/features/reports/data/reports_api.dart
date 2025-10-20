import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';

enum ReportKind {
  educationLevel,
  maritalStatus,
  membershipMeans,
  subcity,
  gender,
}

class ReportsApi {
  final Dio _dio;
  ReportsApi({Dio? dio}) : _dio = dio ?? makeDio();

  String _pathFor(ReportKind kind) {
    switch (kind) {
      case ReportKind.educationLevel:
        return ApiPaths.getEducationLevelByMidib; // /api/GejaKhcAPI/GetEducationLevelByMidib
      case ReportKind.maritalStatus:
        return ApiPaths.getMaritalStatusByMidib;  // /api/GejaKhcAPI/GetMaritalStatusByMidib
      case ReportKind.membershipMeans:
        return ApiPaths.getMembershipMeansByMidib; // /api/GejaKhcAPI/GetMembershipMeansByMidib
      case ReportKind.subcity:
        return ApiPaths.getSubcityByMidib;        // /api/GejaKhcAPI/GetSubcityByMidib
      case ReportKind.gender:
        return ApiPaths.getGenderByMidib;         // /api/GejaKhcAPI/GetGenderByMidib
    }
  }

  Never _throw(DioException e) {
    final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    throw Exception('DioException ${e.response?.statusCode}: $msg');
  }

  /// Each endpoint returns an array of JSON rows with varying columns.
  Future<List<Map<String, dynamic>>> fetch(ReportKind kind) async {
    try {
      final res = await _dio.post(_pathFor(kind)); // your API is POST-without-body
      final list = (res.data as List).cast<dynamic>();
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }
}