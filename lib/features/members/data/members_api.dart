import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../midibs/data/midib.dart';
import 'member.dart';

class MembersApi {
  final Dio _dio;
  MembersApi({Dio? dio}) : _dio = dio ?? makeDio();

  Never _throw(DioException e) {
    final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    throw Exception('DioException ${e.response?.statusCode}: $msg');
  }

  /// Get all members (no params)
  Future<List<Member>> listAll() async {
    try {
      final res = await _dio.post(
        ApiPaths.getAllMembers,
        // no body, JSON default is fine
      );
      final data = (res.data as List).cast<dynamic>();
      return data.map((e) => Member.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// List members by Midib (API: GetMemberList). The backend has historically
  /// required Name + MidibCode (and sometimes a string 'Midib'); we send all.
  Future<List<Member>> listMembersByMidib(Midib midib) async {
    try {
      final body = {
        // IDs for safety
        'Id': midib.id, 'id': midib.id, 'MidibId': midib.id, 'midibId': midib.id,
        // Required fields your server complained about previously
        'Name': midib.name, 'name': midib.name,
        'MidibCode': midib.midibCode, 'midibCode': midib.midibCode,
        // Some actions validate a 'Midib' display/string field
        'Midib': (midib.midibCode?.trim().isNotEmpty ?? false)
            ? midib.midibCode
            : midib.name,
        'midib': (midib.midibCode?.trim().isNotEmpty ?? false)
            ? midib.midibCode
            : midib.name,
      };
      final res = await _dio.post(
        ApiPaths.listMembersByMidib,
        data: body, // JSON
        options: Options(contentType: Headers.jsonContentType),
      );
      final data = (res.data as List).cast<dynamic>();
      return data.map((e) => Member.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Get single member by ID (API: GetMember)
  Future<Member> getMember(String id) async {
    try {
      final body = {
        'Id': id, 'id': id, 'MemberId': id, 'memberId': id,
        'Name': '', 'name': '',
        'MemberCode': '', 'memberCode': '',
        'Member': '', 'member': '',
      };
      final res = await _dio.post(
        ApiPaths.getMember,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      return Member.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Create/update member (API: SetMember)
  Future<void> setMemberX(Member m) async {
    try {
      final body = {
        'Id': m.id, 'id': m.id,
        'Name': m.name, 'name': m.name,
        'MemberCode': m.memberCode, 'memberCode': m.memberCode,
        'MidibId': m.midibId, 'midibId': m.midibId,
      };
      await _dio.post(
        ApiPaths.setMember,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }
  
  Future<void> setMember(Map<String, dynamic> body) async {
    await _dio.post(
      ApiPaths.setMember,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  /// Delete member (API: DeleteMember)
  Future<void> deleteMember(String id) async {
    try {
      final body = {'Id': id, 'id': id, 'MemberId': id, 'memberId': id};
      await _dio.post(
        ApiPaths.deleteMember,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  /// Suggest next member code for a given midib from existing members.
  Future<String> nextMemberCodeForMidib(Midib midib) async {
    final list = await listMembersByMidib(midib);
    final prefix = (midib.midibCode ?? '').trim();
    // Extract trailing number from MemberCode, e.g., "02-0017" -> 17
    final nums = list
        .map((m) => int.tryParse(
              (m.memberCode ?? '')
                  .replaceAll(RegExp(r'^\D+'), '')
                  .replaceAll(RegExp(r'\D'), ''),
            ) ?? 0)
        .toList();
    final maxNum = (nums.isEmpty ? 0 : nums.reduce((a, b) => a > b ? a : b));
    final next = maxNum + 1;
    final padded = next.toString().padLeft(4, '0');
    return prefix.isEmpty ? padded : '$prefix-$padded';
  }
}
