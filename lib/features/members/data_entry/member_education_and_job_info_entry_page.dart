import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../../app/widgets/error_view.dart';

class MemberEducationAndJobInfoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberEducationAndJobInfoEntryPage({super.key, required this.memberId});

  @override
  State<MemberEducationAndJobInfoEntryPage> createState() =>
      _MemberEducationAndJobInfoEntryPageState();
}

class _MemberEducationAndJobInfoEntryPageState
    extends State<MemberEducationAndJobInfoEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final dio = makeDio();

  late Future<void> _initFuture;

  String _memberName = '';
  String _memberCode = '';  

  String? _educationAndJobInfoId;

  // Dropdown data
  List<Map<String, String>> _educationLevels = [];
  List<Map<String, String>> _fieldsOfStudy = [];
  List<Map<String, String>> _jobs = [];
  List<Map<String, String>> _jobTypes = [];

  // Selected values
  String? _selectedEducationLevelId;
  String? _selectedFieldOfStudyId;
  String? _selectedJobId;
  String? _selectedJobTypeId;

  bool _modified = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final memberRes = await dio.post(
		  ApiPaths.getMember,
		  data: { 'Id': widget.memberId, 'id': widget.memberId, 'Name': '', 'name': '', 'MemberCode': '', 'memberCode': ''},
		  options: Options(validateStatus: (s) => true),
		);
	   final memberData = Map<String, dynamic>.from(memberRes.data);
	  
	  _memberName = memberData['name'] ?? '';
	  _memberCode = memberData['memberCode'] ?? '';
      
	  // Load dropdown data in parallel
      final results = await Future.wait([
        dio.post(ApiPaths.getEducationLevelList),
        dio.post(ApiPaths.getFieldOfStudyList),
        dio.post(ApiPaths.getJobList),
        dio.post(ApiPaths.getJobTypeList),
      ]);

      _educationLevels = (results[0].data as List)
          .map((e) => {
                'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
                'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
              })
          .where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
          .toList();

      _fieldsOfStudy = (results[1].data as List)
          .map((e) => {
                'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
                'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
              })
          .where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
          .toList();

      _jobs = (results[2].data as List)
          .map((e) => {
                'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
                'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
              })
          .where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
          .toList();

      _jobTypes = (results[3].data as List)
          .map((e) => {
                'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
                'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
              })
          .where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
          .toList();

      // Load existing data
      final res = await dio.post(
        ApiPaths.getEducationAndJobInfoByMember,
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

      final root = res.data;
      final data = root is Map<String, dynamic>
          ? (root['result'] ?? root)
          : <String, dynamic>{};

      _educationAndJobInfoId =
          data['Id']?.toString() ?? data['id']?.toString();

      setState(() {
        _selectedEducationLevelId =
            (data['EducationLevelId'] ?? data['educationLevelId'])?.toString();
        _selectedFieldOfStudyId =
            (data['FieldOfStudyId'] ?? data['fieldOfStudyId'])?.toString();
        _selectedJobId = (data['JobId'] ?? data['jobId'])?.toString();
        _selectedJobTypeId =
            (data['JobTypeId'] ?? data['jobTypeId'])?.toString();
      });
    } catch (e) {
      debugPrint('❌ Error loading EducationAndJobInfo: $e');
      rethrow;
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
	  ScaffoldMessenger.of(context).showSnackBar(
		const SnackBar(
		  content: Text('እባክዎን * ምልክት ያለባቸውን ሳጥኖች ያስገቡ/ይምረጡ'),
		),
	  );
	  return;
	}

    final body = {
      'Id': _educationAndJobInfoId?.isNotEmpty == true ? _educationAndJobInfoId : '00000000-0000-0000-0000-000000000000',
      'MemberId': widget.memberId,
      'EducationLevelId': _selectedEducationLevelId,
      'FieldOfStudyId': _selectedFieldOfStudyId,
      'JobId': _selectedJobId,
      'JobTypeId': _selectedJobTypeId,
    };

    try {
      final response = await dio.post(
        ApiPaths.setEducationAndJobInfo,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200 &&
          (response.data['exceptionNumber'] == 0)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('የትምህርት እና የሥራ መረጃ ተቀምጧል!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('❌ Save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('መረጃ ማስቀመጥ አልተሳካም።')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የትምህርት እና የሥራ መረጃ'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(
              message:
                  'የትምህርት እና የሥራ መረጃ ለመጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
              onRetry: () => setState(() => _initFuture = _loadInitialData()),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () => _modified = true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
					padding: const EdgeInsets.only(bottom: 12),
					child: Text(
					  '$_memberName ($_memberCode)',
					  style: const TextStyle(
						fontSize: 18,
						fontWeight: FontWeight.bold,
						color: Colors.indigo,
					  ),
					),
				  ),
				  _dropdownField(
                    label: 'የትምህርት ደረጃ',
                    items: _educationLevels,
                    value: _selectedEducationLevelId,
                    onChanged: (v) =>
                        setState(() => _selectedEducationLevelId = v),
                  ),
                  const SizedBox(height: 12),

                  _dropdownField(
                    label: 'የትምህርት መስክ',
                    items: _fieldsOfStudy,
                    value: _selectedFieldOfStudyId,
                    onChanged: (v) =>
                        setState(() => _selectedFieldOfStudyId = v),
                  ),
                  const SizedBox(height: 12),

                  _dropdownField(
                    label: 'የተሰማሩበት የሥራ ዘርፍ',
                    items: _jobs,
                    value: _selectedJobId,
                    onChanged: (v) => setState(() => _selectedJobId = v),
                  ),
                  const SizedBox(height: 12),

                  _dropdownField(
                    label: 'የሥራ ዓይነት',
                    items: _jobTypes,
                    value: _selectedJobTypeId,
                    onChanged: (v) => setState(() => _selectedJobTypeId = v),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required List<Map<String, String>> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value != null && items.any((e) => e['Id'] == value) ? value : null,
      validator: (v) => v == null || v.isEmpty ? '$label ይምረጡ' : null,
	  decoration: InputDecoration(
        labelText: '$label *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e['Id'],
                child: Text(e['Name'] ?? ''),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}