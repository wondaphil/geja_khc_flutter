import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../../app/widgets/error_view.dart';

class MemberMinistryInfoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberMinistryInfoEntryPage({super.key, required this.memberId});

  @override
  State<MemberMinistryInfoEntryPage> createState() =>
      _MemberMinistryInfoEntryPageState();
}

class _MemberMinistryInfoEntryPageState
    extends State<MemberMinistryInfoEntryPage> {
  final dio = makeDio();

  List<Map<String, String>> _memberMinistries = [];
  List<Map<String, String>> _ministryTypes = [];
  List<Map<String, String>> _ministries = [];

  String? _selectedTypeId;
  String? _selectedMinistryId;
  
  String? _editingId;

  bool _loading = false;
  late Future<void> _initFuture;
  
  String _memberName = '';
  String _memberCode = '';

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
	  try {
		final memberRes = await dio.post(
		  ApiPaths.getMember,
		  data: { 'Id': widget.memberId, 'id': widget.memberId, 'Name': '', 'name': '', 'MemberCode': '', 'memberCode': '' },
		  options: Options(validateStatus: (s) => true),
		);
	   final memberData = Map<String, dynamic>.from(memberRes.data);
	  
	  debugPrint('⚠️ Member Data: $memberData');
	  
	  _memberName = memberData['name'] ?? '';
	  _memberCode = memberData['memberCode'] ?? '';
      
	   // Load ministry types
		final typeRes = await dio.post(ApiPaths.getMinistryTypeList);
		_ministryTypes = (typeRes.data as List)
			.map((e) => {
				  'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
				  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
				})
			.where((e) => e['Id']!.isNotEmpty)
			.toList();

		// Load ministries
		final minRes = await dio.post(ApiPaths.getMinistryList);
		_ministries = (minRes.data as List)
			.map((e) => {
				  'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
				  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
				})
			.where((e) => e['Id']!.isNotEmpty)
			.toList();

		// Load existing member ministries
		final res = await dio.post(
		  ApiPaths.getMemberMinistriesByMember,
		  data: {
			'Id': widget.memberId,
			'id': widget.memberId,
			'Name': '',
			'name': '',
			'MemberCode': '',
			'memberCode': '',
		  },
		  options: Options(validateStatus: (s) => true),
		);
		debugPrint('📦 Raw MemberMinistries data: ${res.data}');

		if (res.data != null) {
		  final list = res.data is List ? res.data : [res.data];
		  _memberMinistries = list.map<Map<String, String>>((m) {
			final map = Map<String, dynamic>.from(m);
			final typeId = (map['MinistryTypeId'] ?? map['ministryTypeId'] ?? '').toString();
			final ministryId = (map['MinistryId'] ?? map['ministryId'] ?? '').toString();

			final typeName = _ministryTypes
					.firstWhere((t) => t['Id'] == typeId,
						orElse: () => {'Name': '—'})['Name'] ??
				'—';
			final ministryName = _ministries
					.firstWhere((t) => t['Id'] == ministryId,
						orElse: () => {'Name': '—'})['Name'] ??
				'—';

			return {
			  'Id': (map['Id'] ?? map['id'] ?? '').toString(),
			  'MemberId': (map['MemberId'] ?? map['memberId'] ?? '').toString(),
			  'MinistryTypeId': typeId,
			  'MinistryId': ministryId,
			  'MinistryTypeName': typeName,
			  'MinistryName': ministryName,
			};
		  }).toList();
		}

		// ✅ Trigger rebuild after all async work is done
		if (mounted) setState(() {});
	  } catch (e) {
		debugPrint('❌ Error loading ministries: $e');
		rethrow;
	  }
	}

  Future<void> _addMinistry() async {
    if (_selectedTypeId == null || _selectedMinistryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎን ሁለቱንም ምርጫዎች ይምረጡ።')),
      );
      return;
    }

    setState(() {
      _memberMinistries.add({
        'Id': _editingId ?? '',
        'MemberId': widget.memberId,
        'MinistryTypeId': _selectedTypeId!,
        'MinistryId': _selectedMinistryId!,
        'MinistryTypeName': _ministryTypes
                .firstWhere((e) => e['Id'] == _selectedTypeId)['Name'] ??
            '',
        'MinistryName': _ministries
                .firstWhere((e) => e['Id'] == _selectedMinistryId)['Name'] ??
            '',
      });
      _selectedTypeId = null;
      _selectedMinistryId = null;
	  _editingId = null;
    });
  }

  Future<void> _deleteMinistry(int index) async {
    final item = _memberMinistries[index];
    final id = item['Id'];
    final memberId = widget.memberId;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ማስጠንቀቂያ'),
        content: const Text('ይህንን አገልግሎት መሰረዝ ይፈልጋሉ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('አይ')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('አዎ')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      final res = await dio.post(
		ApiPaths.deleteMemberMinistry,
        data: {'Id': id, 'MemberId': '', 'MinistryId': '', 'MinistryTypeId': ''},
        options: Options(validateStatus: (_) => true),
      );

      if (res.statusCode == 200) {
        setState(() => _memberMinistries.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('አገልግሎቱ ተሰርዟል።')),
        );
      } else {
        throw Exception('Delete failed');
      }
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('መሰረዝ አልተሳካም።')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveMinistries() async {
    if (_memberMinistries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎን ቢያንስ አንድ አገልግሎት ያክሉ።')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      for (final item in _memberMinistries) {
        final body = {
          'Id': item['Id']?.isNotEmpty == true ? item['Id'] : '',
          'MemberId': widget.memberId,
          'MinistryTypeId': item['MinistryTypeId'],
          'MinistryId': item['MinistryId'],
        };

        await dio.post(
          ApiPaths.setMemberMinistry,
          data: body,
          options: Options(
            contentType: Headers.jsonContentType,
            validateStatus: (_) => true,
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('የአገልግሎት መረጃ ተቀምጧል!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('መረጃ ማስቀመጥ አልተሳካም።')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የአገልግሎት መረጃ'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveMinistries),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorView(
                  message:
                      '⚠️ የአገልግሎት መረጃ መጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
                  onRetry: () =>
                      setState(() => _initFuture = _loadInitialData()),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
				  crossAxisAlignment: CrossAxisAlignment.start,
				  children: [
					_memberHeader(),
                    Expanded(
                      child: _memberMinistries.isEmpty
                          ? const Center(
                              child: Text('አገልግሎት አልተጨመረም።'),
                            )
                          : ListView.builder(
                              itemCount: _memberMinistries.length,
                              itemBuilder: (context, i) {
                                final m = _memberMinistries[i];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: const Icon(Icons.church),
                                    title: Text(m['MinistryName'] ?? ''),
                                    subtitle:
                                        Text(m['MinistryTypeName'] ?? '—'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            setState(() {
                                              _editingId = m['Id'];
											  _selectedTypeId = m['MinistryTypeId'];
                                              _selectedMinistryId = m['MinistryId'];
                                              _memberMinistries.removeAt(i);
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteMinistry(i),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(thickness: 1),
                    DropdownButtonFormField<String>(
                      value: _selectedTypeId,
                      decoration: const InputDecoration(
                        labelText: 'የአገልግሎት አይነት *',
                        border: OutlineInputBorder(),
                      ),
                      items: _ministryTypes
                          .map((e) => DropdownMenuItem<String>(
                                value: e['Id'],
                                child: Text(e['Name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTypeId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedMinistryId,
                      decoration: const InputDecoration(
                        labelText: 'የአገልግሎት ስም *',
                        border: OutlineInputBorder(),
                      ),
                      items: _ministries
                          .map((e) => DropdownMenuItem<String>(
                                value: e['Id'],
                                child: Text(e['Name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMinistryId = v),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('አገልግሎት ጨምር'),
                        onPressed: _addMinistry,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (_loading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('በማስቀመጥ ላይ...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
    Widget _memberHeader() {
	  return Container(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
		margin: const EdgeInsets.only(bottom: 16),
		decoration: BoxDecoration(
		  color: Colors.indigo.shade50,
		  borderRadius: BorderRadius.circular(12),
		  boxShadow: [
			BoxShadow(
			  color: Colors.black.withOpacity(0.1),
			  blurRadius: 6,
			  offset: const Offset(0, 3),
			),
		  ],
		),
		child: Row(
		  children: [
			Icon(Icons.person, color: Theme.of(context).primaryColor, size: 28),
			const SizedBox(width: 12),
			Expanded(
			  child: Text(
				'$_memberName ($_memberCode)',
				style: TextStyle(
				  fontSize: 18,
				  fontWeight: FontWeight.bold,
				  color: Theme.of(context).primaryColor
				),
				overflow: TextOverflow.ellipsis,
			  ),
			),
		  ],
		),
	  );
  }
}