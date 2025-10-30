import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';

// ===== Existing Report Kinds (by Midib) =====
enum ReportKind {
  educationLevel,
  maritalStatus,
  membershipMeans,
  subcity,
  gender,
}

// ===== New Member Count Report Kinds =====
enum MemberCountKind {
  byMidib,
  byMembershipMeans,
  byMembershipYear,
  byMinistryCurrent,
  byMinistryPrevious,
  byGender,
  byMaritalStatus,
  byEducationLevel,
  byFieldOfStudy,
  byJob,
  byJobType,
  bySubcity,
  byHouseOwnershipType,
}

class ReportsApi {
  final Dio _dio;
  ReportsApi({Dio? dio}) : _dio = dio ?? makeDio();

  // =============== EXISTING REPORTS (By Midib) ===============
  String _pathFor(ReportKind kind) {
    switch (kind) {
      case ReportKind.educationLevel:
        return ApiPaths.getEducationLevelByMidib;
      case ReportKind.maritalStatus:
        return ApiPaths.getMaritalStatusByMidib;
      case ReportKind.membershipMeans:
        return ApiPaths.getMembershipMeansByMidib;
      case ReportKind.subcity:
        return ApiPaths.getSubcityByMidib;
      case ReportKind.gender:
        return ApiPaths.getGenderByMidib;
    }
  }

  /// Fetch reports grouped by Midib (existing feature)
  Future<List<Map<String, dynamic>>> fetch(ReportKind kind) async {
    try {
      final res = await _dio.post(_pathFor(kind));
      final list = (res.data as List).cast<dynamic>();
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  // =============== NEW REPORTS (By Parameters) ===============
  String _pathForMemberCount(MemberCountKind kind) {
    switch (kind) {
      case MemberCountKind.byMidib:
        return ApiPaths.membersCountByMidib;
      case MemberCountKind.byMembershipMeans:
        return ApiPaths.membersCountByMembershipMeans;
      case MemberCountKind.byMembershipYear:
        return ApiPaths.membersCountByMembershipYear;
      case MemberCountKind.byMinistryCurrent:
        return ApiPaths.membersCountByMinistryCurrent;
      case MemberCountKind.byMinistryPrevious:
        return ApiPaths.membersCountByMinistryPrevious;
      case MemberCountKind.byGender:
        return ApiPaths.membersCountByGender;
      case MemberCountKind.byMaritalStatus:
        return ApiPaths.membersCountByMaritalStatus;
      case MemberCountKind.byEducationLevel:
        return ApiPaths.membersCountByEducationLevel;
      case MemberCountKind.byFieldOfStudy:
        return ApiPaths.membersCountByFieldOfStudy;
      case MemberCountKind.byJob:
        return ApiPaths.membersCountByJob;
      case MemberCountKind.byJobType:
        return ApiPaths.membersCountByJobType;
      case MemberCountKind.bySubcity:
        return ApiPaths.membersCountBySubcity;
      case MemberCountKind.byHouseOwnershipType:
        return ApiPaths.membersCountByHouseOwnershipType;
    }
  }

  /// Unified method for “Member Count by Parameter” reports
  Future<List<Map<String, dynamic>>> fetchMemberCount(MemberCountKind kind) async {
    try {
      final res = await _dio.post(_pathForMemberCount(kind));
      final list = (res.data as List).cast<dynamic>();
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  // Shortcut wrappers (optional)
  Future<List<Map<String, dynamic>>> membersCountByMidib() =>
      fetchMemberCount(MemberCountKind.byMidib);
  Future<List<Map<String, dynamic>>> membersCountByMembershipMeans() =>
      fetchMemberCount(MemberCountKind.byMembershipMeans);
  Future<List<Map<String, dynamic>>> membersCountByMembershipYear() =>
      fetchMemberCount(MemberCountKind.byMembershipYear);
  Future<List<Map<String, dynamic>>> membersCountByMinistryCurrent() =>
      fetchMemberCount(MemberCountKind.byMinistryCurrent);
  Future<List<Map<String, dynamic>>> membersCountByMinistryPrevious() =>
      fetchMemberCount(MemberCountKind.byMinistryPrevious);
  Future<List<Map<String, dynamic>>> membersCountByGender() =>
      fetchMemberCount(MemberCountKind.byGender);
  Future<List<Map<String, dynamic>>> membersCountByMaritalStatus() =>
      fetchMemberCount(MemberCountKind.byMaritalStatus);
  Future<List<Map<String, dynamic>>> membersCountByEducationLevel() =>
      fetchMemberCount(MemberCountKind.byEducationLevel);
  Future<List<Map<String, dynamic>>> membersCountByFieldOfStudy() =>
      fetchMemberCount(MemberCountKind.byFieldOfStudy);
  Future<List<Map<String, dynamic>>> membersCountByJob() =>
      fetchMemberCount(MemberCountKind.byJob);
  Future<List<Map<String, dynamic>>> membersCountByJobType() =>
      fetchMemberCount(MemberCountKind.byJobType);
  Future<List<Map<String, dynamic>>> membersCountBySubcity() =>
      fetchMemberCount(MemberCountKind.bySubcity);
  Future<List<Map<String, dynamic>>> membersCountByHouseOwnershipType() =>
      fetchMemberCount(MemberCountKind.byHouseOwnershipType);

  // =============== Error Handling ===============
  Never _throw(DioException e) {
    final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    throw Exception('DioException ${e.response?.statusCode}: $msg');
  }
}