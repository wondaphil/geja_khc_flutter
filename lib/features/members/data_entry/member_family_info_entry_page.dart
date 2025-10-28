import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../../app/widgets/error_view.dart';

class MemberFamilyInfoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberFamilyInfoEntryPage({super.key, required this.memberId});

  @override
  State<MemberFamilyInfoEntryPage> createState() =>
      _MemberFamilyInfoEntryPageState();
}

class _MemberFamilyInfoEntryPageState extends State<MemberFamilyInfoEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final dio = makeDio();

  late Future<void> _initFuture;
  
  String _memberName = '';
  String _memberCode = '';  

  String? _familyInfoId;
  List<Map<String, String>> _maritalStatuses = [];

  String? _selectedMaritalStatusId;
  int? _marriageYear;
  String _spouseName = '';

  // Sons
  int? _noOfSons;
  int? _noOfSons1to5;
  int? _noOfSons6to12;
  int? _noOfSons13to20;
  int? _noOfSonsAbove20;

  // Daughters
  int? _noOfDaughters;
  int? _noOfDaughters1to5;
  int? _noOfDaughters6to12;
  int? _noOfDaughters13to20;
  int? _noOfDaughtersAbove20;

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
		  data: { 'Id': widget.memberId, 'id': widget.memberId, 'Name': '', 'name': '', 'MemberCode': '', 'memberCode': '' },
		  options: Options(validateStatus: (s) => true),
		);
	   final memberData = Map<String, dynamic>.from(memberRes.data);
	  
	  _memberName = memberData['name'] ?? '';
	  _memberCode = memberData['memberCode'] ?? '';
      
	  final maritalRes = await dio.post(ApiPaths.getMaritalStatusList);
      _maritalStatuses = (maritalRes.data as List)
          .map((e) => {
                'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
                'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
              })
          .where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
          .toList();

      final res = await dio.post(
        ApiPaths.getFamilyInfoByMember,
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

      _familyInfoId = data['Id']?.toString() ?? data['id']?.toString();

      setState(() {
        _selectedMaritalStatusId =
            (data['MaritalStatusId'] ?? data['maritalStatusId'])?.toString();
        _marriageYear = data['MarriageYear'] ?? data['marriageYear'];
        _spouseName = data['SpouseName'] ?? data['spouseName'] ?? '';

        // Sons
        _noOfSons = int.tryParse(data['NoOfSons']?.toString() ?? data['noOfSons']?.toString() ?? '');
        _noOfSons1to5 = int.tryParse(data['NoOfSons1to5']?.toString() ?? data['noOfSons1to5']?.toString() ?? '');
        _noOfSons6to12 = int.tryParse(data['NoOfSons6to12']?.toString() ?? data['noOfSons6to12']?.toString() ?? '');
        _noOfSons13to20 = int.tryParse(data['NoOfSons13to20']?.toString() ?? data['noOfSons13to20']?.toString() ?? '');
        _noOfSonsAbove20 = int.tryParse(data['NoOfSonsAbove20']?.toString() ?? data['noOfSonsAbove20']?.toString() ?? '');

        // Daughters
        _noOfDaughters = int.tryParse(data['NoOfDaughters']?.toString() ?? data['noOfDaughters']?.toString() ?? '');
        _noOfDaughters1to5 = int.tryParse(data['NoOfDaughters1to5']?.toString() ?? data['noOfDaughters1to5']?.toString() ?? '');
        _noOfDaughters6to12 = int.tryParse(data['NoOfDaughters6to12']?.toString() ?? data['noOfDaughters6to12']?.toString() ?? '');
        _noOfDaughters13to20 = int.tryParse(data['NoOfDaughters13to20']?.toString() ?? data['noOfDaughters13to20']?.toString() ?? '');
        _noOfDaughtersAbove20 = int.tryParse(data['NoOfDaughtersAbove20']?.toString() ?? data['noOfDaughtersAbove20']?.toString() ?? '');
      });
    } catch (e) {
      debugPrint('❌ Error loading FamilyInfo: $e');
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
      'Id': _familyInfoId?.isNotEmpty == true ? _familyInfoId : '00000000-0000-0000-0000-000000000000',
      'MemberId': widget.memberId,
      'MaritalStatusId': _selectedMaritalStatusId,
      'MarriageYear': _marriageYear ?? null,
      'SpouseName': _spouseName,
      // Sons
      'NoOfSons': _noOfSons,
      'NoOfSons1to5': _noOfSons1to5,
      'NoOfSons6to12': _noOfSons6to12,
      'NoOfSons13to20': _noOfSons13to20,
      'NoOfSonsAbove20': _noOfSonsAbove20,
      // Daughters
      'NoOfDaughters': _noOfDaughters,
      'NoOfDaughters1to5': _noOfDaughters1to5,
      'NoOfDaughters6to12': _noOfDaughters6to12,
      'NoOfDaughters13to20': _noOfDaughters13to20,
      'NoOfDaughtersAbove20': _noOfDaughtersAbove20,
    };

	try {
      final response = await dio.post(
        ApiPaths.setFamilyInfo,
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
          const SnackBar(content: Text('የቤተሰብ መረጃ ተቀምጧል!')),
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
        title: const Text('የቤተሰብ መረጃ'),
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
                  '⚠️ የቤተሰብ መረጃ መጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
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
                  _memberHeader(),
				  DropdownButtonFormField<String>(
                    value: _selectedMaritalStatusId != null &&
                            _maritalStatuses.any(
                                (m) => m['Id'] == _selectedMaritalStatusId)
                        ? _selectedMaritalStatusId
                        : null,
                    validator: (v) => v == null || v.isEmpty ? 'የጋብቻ ሁኔታ ይምረጡ' : null,
					decoration: const InputDecoration(
                      labelText: 'የጋብቻ ሁኔታ *',
                      border: OutlineInputBorder(),
                    ),
                    items: _maritalStatuses
                        .map((m) => DropdownMenuItem<String>(
                              value: m['Id'],
                              child: Text(m['Name'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMaritalStatusId = v),
                  ),
                  const SizedBox(height: 12),

                  _dropdown<int>(
                    label: 'የጋብቻ ዘመን',
                    value: _marriageYear,
                    items: _ethiopianYears(),
                    onChanged: (v) => setState(() => _marriageYear = v),
                  ),
                  const SizedBox(height: 12),

                  _textField(
                    label: 'የባል/ሚስት ስም',
                    initialValue: _spouseName,
                    onChanged: (v) => _spouseName = v,
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  const Text('የወንዶች ልጆች ብዛት',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
					  _numberField(label: 'ጠቅላላ', initialValue: _noOfSons, onChanged: (v) => _noOfSons = v),
					  _numberField(label: '1–5 ዓመት', initialValue: _noOfSons1to5, onChanged: (v) => _noOfSons1to5 = v),
					  _numberField(label: '6–12 ዓመት', initialValue: _noOfSons6to12, onChanged: (v) => _noOfSons6to12 = v),
					  _numberField(label: '13–20 ዓመት', initialValue: _noOfSons13to20, onChanged: (v) => _noOfSons13to20 = v),
					  _numberField(label: 'ከ20 ዓመት በላይ', initialValue: _noOfSonsAbove20, onChanged: (v) => _noOfSonsAbove20 = v),
					],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  const Text('የሴት ልጆች ብዛት',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
					  _numberField(label: 'ጠቅላላ', initialValue: _noOfDaughters, onChanged: (v) => _noOfDaughters = v),
					  _numberField(label: '1–5 ዓመት', initialValue: _noOfDaughters1to5, onChanged: (v) => _noOfDaughters1to5 = v),
					  _numberField(label: '6–12 ዓመት', initialValue: _noOfDaughters6to12, onChanged: (v) => _noOfDaughters6to12 = v),
					  _numberField(label: '13–20 ዓመት', initialValue: _noOfDaughters13to20, onChanged: (v) => _noOfDaughters13to20 = v),
					  _numberField(label: 'ከ20 ዓመት በላይ', initialValue: _noOfDaughtersAbove20, onChanged: (v) => _noOfDaughtersAbove20 = v),
					],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<int>> _ethiopianYears() {
    final now = DateTime.now();
    final currentYear = now.year;
    return List.generate(
        currentYear - 1900 + 1,
        (i) => DropdownMenuItem(
            value: currentYear - i, child: Text('${currentYear - i}')));
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _textField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _numberField({
	  required String label,
	  required int? initialValue,
	  required ValueChanged<int?> onChanged,
	}) {
	  return SizedBox(
		width: (MediaQuery.of(context).size.width - 48) / 2,
		child: TextFormField(
		  initialValue: initialValue?.toString() ?? '',
		  keyboardType: TextInputType.number,
		  decoration: InputDecoration(
			labelText: label,
			border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
		  ),
		  onChanged: (v) {
			final parsed = int.tryParse(v.trim());
			onChanged(parsed);
		  },
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