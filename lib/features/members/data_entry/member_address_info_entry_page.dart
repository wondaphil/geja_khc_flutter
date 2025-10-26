import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../../app/widgets/error_view.dart';

class MemberAddressInfoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberAddressInfoEntryPage({super.key, required this.memberId});

  @override
  State<MemberAddressInfoEntryPage> createState() =>
      _MemberAddressInfoEntryPageState();
}

class _MemberAddressInfoEntryPageState
    extends State<MemberAddressInfoEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final dio = makeDio();

  late Future<void> _initFuture;

  String _memberName = '';
  String _memberCode = '';  

  // For storing the id
  String? _addressInfoId;
  
  // dropdown data
  List<Map<String, String>> _subcities = [];
  List<Map<String, String>> _houseOwnerships = [];

  // field values
  String? _selectedSubcityId;
  String? _selectedHouseOwnershipId;
  String _woreda = '';
  String _kebele = '';
  String _houseNo = '';
  String _homePhone = '';
  String _officePhone = '';
  String _mobilePhone = '';
  String _email = '';

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
      
	  // Load dropdowns
		final subRes = await dio.post(ApiPaths.getSubcityList);
		_subcities = (subRes.data as List)
			.map((e) => {
				  'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
				  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
				})
			.where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
			.toList();

		final houseRes = await dio.post(ApiPaths.getHouseOwnershipList);
		_houseOwnerships = (houseRes.data as List)
			.map((e) => {
				  'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
				  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
				})
			.where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
			.toList();

		// Load existing AddressInfo by Member
		final res = await dio.post(
		  ApiPaths.getAddressInfoByMember,
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

		//final data = Map<String, dynamic>.from(res.data);
		final root = res.data;
		final data = root is Map<String, dynamic>
			? (root['result'] ?? root)
			: <String, dynamic>{};

		_addressInfoId = data['Id']?.toString() ?? data['id']?.toString();

		setState(() {
		  _addressInfoId = data['Id']?.toString() ?? data['id']?.toString();
		  _selectedSubcityId = (data['SubcityId'] ?? data['subcityId'])?.toString();
		  _selectedHouseOwnershipId =
			  (data['HouseOwnershipId'] ?? data['houseOwnershipId'])?.toString();
		  _woreda = data['Woreda'] ?? data['woreda'] ?? '';
		  _kebele = data['Kebele'] ?? data['kebele'] ?? '';
		  _houseNo = data['HouseNo'] ?? data['houseNo'] ?? '';
		  _homePhone = data['HomePhoneNo'] ?? data['homePhoneNo'] ?? '';
		  _officePhone = data['OfficePhoneNo'] ?? data['officePhoneNo'] ?? '';
		  _mobilePhone = data['MobilePhoneNo'] ?? data['mobilePhoneNo'] ?? '';
		  _email = data['Email'] ?? data['email'] ?? '';
		});
	  } catch (e) {
		debugPrint('❌ Error loading AddressInfo: $e');
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
		'Id': _addressInfoId?.isNotEmpty == true ? _addressInfoId : '00000000-0000-0000-0000-000000000000',
		'MemberId': widget.memberId,
		'SubcityId': _selectedSubcityId,
		'Woreda': _woreda,
		'Kebele': _kebele,
		'HouseNo': _houseNo,
		'HouseOwnershipId': _selectedHouseOwnershipId,
		'HomePhoneNo': _homePhone,
		'OfficePhoneNo': _officePhone,
		'MobilePhoneNo': _mobilePhone,
		'Email': _email,
	  };
	  
	  try {
		final response = await dio.post(
		  ApiPaths.setAddressInfo,
		  data: body,
		  options: Options(
			contentType: Headers.jsonContentType,
			validateStatus: (_) => true,
		  ),
		);

		if (response.statusCode == 200 && (response.data['exceptionNumber'] == 0)) {
		  if (!mounted) return;
		  ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(content: Text('የአድራሻ መረጃ ተቀምጧል!')),
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

  Future<bool> _confirmExit() async {
    if (!_modified) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ማስጠንቀቂያ'),
        content: const Text('ያልተያዘ መረጃ አለ። መውጣት ይፈልጋሉ?'),
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
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('የአድራሻ መረጃ'),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
          ],
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
                    'የአድራሻ መረጃ ለመጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
                onRetry: () =>
                    setState(() => _initFuture = _loadInitialData()),
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
				  DropdownButtonFormField<String>(
                      value: _selectedSubcityId != null &&
                              _subcities
                                  .any((s) => s['Id'] == _selectedSubcityId)
                          ? _selectedSubcityId
                          : null,
                      validator: (v) => v == null || v.isEmpty ? 'ክፍለ ከተማ ይምረጡ' : null,
					  decoration: const InputDecoration(
                        labelText: 'ክፍለ ከተማ *',
                        border: OutlineInputBorder(),
                      ),
                      items: _subcities
                          .map((s) => DropdownMenuItem<String>(
                                value: s['Id'],
                                child: Text(s['Name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubcityId = v),
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'ወረዳ',
                      initialValue: _woreda,
                      onChanged: (v) => _woreda = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'ቀበሌ',
                      initialValue: _kebele,
                      onChanged: (v) => _kebele = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'የቤት ቁጥር',
                      initialValue: _houseNo,
                      onChanged: (v) => _houseNo = v,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedHouseOwnershipId != null &&
                              _houseOwnerships.any(
                                  (h) => h['Id'] == _selectedHouseOwnershipId)
                          ? _selectedHouseOwnershipId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'የቤት ባለቤትነት',
                        border: OutlineInputBorder(),
                      ),
                      items: _houseOwnerships
                          .map((h) => DropdownMenuItem<String>(
                                value: h['Id'],
                                child: Text(h['Name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedHouseOwnershipId = v),
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'የቤት ስልክ',
                      initialValue: _homePhone,
                      onChanged: (v) => _homePhone = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'የቢሮ ስልክ',
                      initialValue: _officePhone,
                      onChanged: (v) => _officePhone = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'ሞባይል',
                      initialValue: _mobilePhone,
                      onChanged: (v) => _mobilePhone = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'ኢሜይል',
                      initialValue: _email,
                      onChanged: (v) => _email = v,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
}