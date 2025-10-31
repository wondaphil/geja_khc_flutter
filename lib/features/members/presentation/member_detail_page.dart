import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../data/members_api.dart';
import '../data/member.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';

class MemberDetailPage extends StatefulWidget {
  final String id;
  const MemberDetailPage({super.key, required this.id});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  final _api = MembersApi();
  late Future<Member> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getMember(widget.id);
  }

  String _dashIfEmpty(String? s) {
    final t = (s ?? '').trim();
    return t.isEmpty ? '—' : t;
  }

  String _dashIfNullInt(int? v) => v == null ? '—' : v.toString();

  Future<String> _fetchGenderName(String? genderId) async {
    final id = (genderId ?? '').trim();
    if (id.isEmpty) return '—';
    try {
      final dio = makeDio();
      final body = {'Id': id, 'id': id, 'Name': '', 'name': ''};
      final res = await dio.post(ApiPaths.getGender, data: body);
      final data = Map<String, dynamic>.from(res.data as Map);
      final name = (data['Name'] ?? data['name'])?.toString();
      return (name == null || name.trim().isEmpty) ? '—' : name.trim();
    } catch (_) {
      return '—';
    }
  }

  Future<String> _fetchMidibName(String? midibId) async {
    final id = (midibId ?? '').trim();
    if (id.isEmpty) return '—';
    try {
      final dio = makeDio();
      final body = {'Id': id, 'id': id, 'MidibCode': '', 'Name': '', 'name': ''};
      final res = await dio.post(ApiPaths.getMidib, data: body);
      final data = Map<String, dynamic>.from(res.data as Map);
      final name = (data['Name'] ?? data['name'])?.toString();
      return (name == null || name.trim().isEmpty) ? '—' : name.trim();
    } catch (_) {
      return '—';
    }
  }

  // ✅ Fetch member photo (same logic as full-detail page)
  Future<Map<String, dynamic>> _fetchMemberPhoto() async {
    final dio = makeDio();
    final res = await dio.post(
      ApiPaths.getMemberPhotoByMember,
      data: {
        'Id': widget.id,
        'id': widget.id,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load MemberPhoto');
    }

    final data = Map<String, dynamic>.from(res.data);
    final photoBase64 = data['Photo'] ?? data['photo'];
    final remark = data['Remark'] ?? data['remark'];

    Uint8List? imageBytes;
    if (photoBase64 != null && photoBase64.toString().isNotEmpty) {
      try {
        imageBytes = base64Decode(photoBase64.toString());
      } catch (e) {
        print('Error decoding photo: $e');
      }
    }

    return {'imageBytes': imageBytes, 'remark': remark};
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ማረጋገጫ'),
        content: const Text('የአባሉን ሙሉ መረጃ ለመሰረዝ እርግጠኛ ነህ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ተወው')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('አዎን')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _api.deleteMember(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('አባሉ በትክክል ተሰርዟል')),
      );
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('መሰረዝ አልተሳካም።')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Member>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final error = snap.hasError ? snap.error.toString() : null;
        final member = snap.data;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(_dashIfEmpty(member?.name ?? (loading ? '…' : 'አባል'))),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') _confirmAndDelete(context);
                },
                itemBuilder: (c) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('ሰርዝ', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),

          body: Builder(
            builder: (_) {
              if (loading) return const Center(child: CircularProgressIndicator());
              if (error != null) {
                return Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                );
              }

              final m = member!;
              final genderFuture = _fetchGenderName(m.genderId);
              final midibFuture = _fetchMidibName(m.midibId);
              final photoFuture = _fetchMemberPhoto();
              final etYear = _ethiopianYearNow(DateTime.now());
              final age = (m.birthYear != null) ? (etYear - m.birthYear!) : null;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 👇 Compact, centered, square photo (not full-width)
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: photoFuture,
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final imageBytes = snap.data?['imageBytes'] as Uint8List?;
                          if (imageBytes == null) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person, size: 70, color: Colors.white70),
                            );
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.cover, // fills box neatly without stretching
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1.2),

                  _row('ስም', _dashIfEmpty(m.name)),
                  _row('የአባል ኮድ', _dashIfEmpty(m.memberCode)),
                  _row('የእናት ስም', _dashIfEmpty(m.motherName)),
                  _rowFuture('ፆታ', genderFuture),
                  _row('ዕድሜ', age == null ? '—' : '$age'),
                  _rowFuture('ምድብ', midibFuture),
                  _row('የአባልነት ዘመን', _dashIfNullInt(m.membershipYear)),
                  _row('ማብራሪያ', _dashIfEmpty(m.remark)),
                ],
              );
            },
          ),

          floatingActionButton: (member == null)
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.push('/members/${member.id}/full_detail'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('ዝርዝር መረጃ አሳይ'),
                ),
        );
      },
    );
  }

  int _ethiopianYearNow(DateTime now) {
    final y = now.year;
    bool isGregorianLeap(int year) =>
        (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
    final newYearDay = isGregorianLeap(y + 1) ? 12 : 11;
    final beforeNewYear =
        (now.month < 9) || (now.month == 9 && now.day < newYearDay);
    return beforeNewYear ? y - 8 : y - 7;
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _rowFuture(String label, Future<String> fut) {
    return FutureBuilder<String>(
      future: fut,
      builder: (context, snap) {
        final value = (snap.connectionState != ConnectionState.done)
            ? '…'
            : (snap.data ?? '—');
        return _row(label, value);
      },
    );
  }
}