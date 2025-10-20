import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../midibs/data/midib.dart';
import '../../midibs/data/midib_api.dart';
import '../data/members_api.dart';
import '../../../app/widgets/error_view.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import 'package:dio/dio.dart';

class MemberBasicInfoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberBasicInfoEntryPage({super.key, required this.memberId});

  @override
  State<MemberBasicInfoEntryPage> createState() =>
      _MemberBasicInfoEntryPageState();
}

class _MemberBasicInfoEntryPageState extends State<MemberBasicInfoEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = MembersApi();
  final _midibApi = MidibApi();
  final dio = makeDio();

  late Future<void> _initFuture;

  List<Midib> _midibs = [];
  List<Map<String, String>> _genders = [];
  List<Map<String, String>> _months = [];
  List<Map<String, String>> _membershipMeans = [];

  String? _selectedGenderId;
  String? _selectedMidibId;
  String? _selectedBirthMonthId;
  String? _selectedMembershipMonthId;
  String? _selectedMembershipMeansId;
  int? _birthDate;
  int? _birthYear;
  int? _membershipDate;
  int? _membershipYear;
  String _name = '';
  String _memberCode = '';
  String _noMinistryReason1 = '';
  String _noMinistryReason2 = '';
  String _remark = '';

  bool _modified = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
	final genderRes = await dio.post(ApiPaths.getGenderList);
	_genders = (genderRes.data as List)
		.map((e) => {
			  'Id': e['id']?.toString() ?? e['Id']?.toString() ?? '',
			  'Name': e['name']?.toString() ?? e['Name']?.toString() ?? '',
			})
		.where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
		.toList();
		
    final monthRes = await dio.post(ApiPaths.getMonthList);
	_months = (monthRes.data as List)
		.map((e) => {
			  'Id': e['Id']?.toString() ??
				  e['id']?.toString() ??
				  e['birthMonthId']?.toString() ??
				  e['membershipMonthId']?.toString() ??
				  '',
			  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
			})
		.where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
		.toList();

    final meansRes = await dio.post(ApiPaths.getMembershipMeansList);
	_membershipMeans = (meansRes.data as List)
		.map((e) => {
			  'Id': e['Id']?.toString() ?? e['id']?.toString() ?? '',
			  'Name': e['Name']?.toString() ?? e['name']?.toString() ?? '',
			})
		.where((e) => e['Id']!.isNotEmpty && e['Name']!.isNotEmpty)
		.toList();
		
	_midibs = await _midibApi.listMidibs();

    final member = await _api.getMember(widget.memberId);

    setState(() {
      _name = member.name;
      _memberCode = member.memberCode;
      _selectedGenderId = member.genderId;
      _selectedMidibId = member.midibId;
      _selectedBirthMonthId =
          member.birthMonthId?.isNotEmpty == true ? member.birthMonthId : null;
      _selectedMembershipMonthId =
          member.membershipMonthId?.isNotEmpty == true
              ? member.membershipMonthId
              : null;
      _selectedMembershipMeansId =
          member.membershipMeansId?.isNotEmpty == true
              ? member.membershipMeansId
              : null;
      _birthDate = member.birthDate;
      _birthYear = member.birthYear;
      _membershipDate = member.membershipDate;
      _membershipYear = member.membershipYear;
      _noMinistryReason1 = member.noMinistryReason ?? '';
      _noMinistryReason2 = member.noMinistryReason2 ?? '';
      _remark = member.remark ?? '';
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'Id': widget.memberId,
      'Name': _name,
      'MemberCode': _memberCode,
      'GenderId': _selectedGenderId,
      'MidibId': _selectedMidibId,
      'BirthMonthId': _selectedBirthMonthId,
      'BirthDate': _birthDate,
      'BirthYear': _birthYear,
      'MembershipMonthId': _selectedMembershipMonthId,
      'MembershipDate': _membershipDate,
      'MembershipYear': _membershipYear,
      'MembershipMeansId': _selectedMembershipMeansId,
      'NoMinistryReason': _noMinistryReason1,
      'NoMinistryReason2': _noMinistryReason2,
      'Remark': _remark,
    };

    await dio.post(ApiPaths.setMember,
        data: body, options: Options(contentType: Headers.jsonContentType));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('መረጃ ተቀምጧል!')));
    Navigator.pop(context, true);
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
          title: const Text('መሠረታዊ መረጃ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
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
                    'መረጃ ለመጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
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
                    _textField(
                      label: 'ስም',
                      initialValue: _name,
                      onChanged: (v) => _name = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _memberCode,
                      readOnly: true,
                      style: const TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        labelText: 'የአባል ኮድ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
					  value: _selectedGenderId != null &&
							  _genders.any((g) => g['Id'] == _selectedGenderId)
						  ? _selectedGenderId
						  : null,
					  decoration: const InputDecoration(
						labelText: 'ፆታ',
						border: OutlineInputBorder(),
					  ),
					  items: _genders
						  .map((g) => DropdownMenuItem<String>(
								value: g['Id'],
								child: Text(g['Name'] ?? ''),
							  ))
						  .toList(),
					  onChanged: (v) => setState(() => _selectedGenderId = v),
					),
                    const SizedBox(height: 12),

                    _dropdown<String>(
                      label: 'ምድብ',
                      value: _selectedMidibId,
                      items: _midibs
                          .map((m) =>
                              DropdownMenuItem(value: m.id, child: Text(m.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMidibId = v),
                    ),
                    const SizedBox(height: 12),

                    // Birth info
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
						  width: double.infinity,
						  child: DropdownButtonFormField<String>(
							value: _selectedBirthMonthId,
							decoration: const InputDecoration(
							  labelText: 'ወር (የትውልድ)',
							  border: OutlineInputBorder(),
							),
							items: _months
								.map((m) => DropdownMenuItem<String>(
									  value: m['Id'],
									  child: Text(m['Name'] ?? ''),
									))
								.toList(),
							onChanged: (v) => setState(() => _selectedBirthMonthId = v),
						  ),
						),
                        SizedBox(
                          width: 100,
                          child: _dropdown<int>(
                            label: 'ቀን',
                            value: _birthDate,
                            items: _numberDropdownItems(1, 30),
                            onChanged: (v) => setState(() => _birthDate = v),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: _dropdown<int>(
                            label: 'አመት',
                            value: _birthYear,
                            items: _ethiopianYears(),
                            onChanged: (v) => setState(() => _birthYear = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Membership info
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
						  width: double.infinity,
						  child: DropdownButtonFormField<String>(
							value: _selectedMembershipMonthId,
							decoration: const InputDecoration(
							  labelText: 'ወር (የአባልነት)',
							  border: OutlineInputBorder(),
							),
							items: _months
								.map((m) => DropdownMenuItem<String>(
									  value: m['Id'],
									  child: Text(m['Name'] ?? ''),
									))
								.toList(),
							onChanged: (v) => setState(() => _selectedMembershipMonthId = v),
						  ),
						),
                        SizedBox(
                          width: 100,
                          child: _dropdown<int>(
                            label: 'ቀን',
                            value: _membershipDate,
                            items: _numberDropdownItems(1, 30),
                            onChanged: (v) =>
                                setState(() => _membershipDate = v),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: _dropdown<int>(
                            label: 'አመት',
                            value: _membershipYear,
                            items: _ethiopianYears(),
                            onChanged: (v) =>
                                setState(() => _membershipYear = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

					DropdownButtonFormField<String>(
					  value: _selectedMembershipMeansId,
					  decoration: const InputDecoration(
						labelText: 'የአባልነት መንገድ',
						border: OutlineInputBorder(),
					  ),
					  items: _membershipMeans
						  .map((m) => DropdownMenuItem<String>(
								value: m['Id'],
								child: Text(m['Name'] ?? ''),
							  ))
						  .toList(),
					  onChanged: (v) => setState(() => _selectedMembershipMeansId = v),
					),
					const SizedBox(height: 12),

                    _textField(
                      label: 'የአገልግሎት አለመኖር ምክንያት 1',
                      initialValue: _noMinistryReason1,
                      onChanged: (v) => _noMinistryReason1 = v,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'የአገልግሎት አለመኖር ምክንያት 2',
                      initialValue: _noMinistryReason2,
                      onChanged: (v) => _noMinistryReason2 = v,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'ማስታወሻ',
                      initialValue: _remark,
                      onChanged: (v) => _remark = v,
                      maxLines: 4,
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

  List<DropdownMenuItem<int>> _numberDropdownItems(int min, int max) {
    return List.generate(
        max - min + 1,
        (i) =>
            DropdownMenuItem(value: min + i, child: Text('${min + i}')));
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
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}