import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../midibs/data/midib.dart';
import '../../members/data/member.dart';
import '../../members/data/members_api.dart';
import '../../midibs/data/midib_api.dart';
import '../../../app/widgets/error_view.dart';
import '../../../app/widgets/app_drawer.dart';

class MemberDataEntryPage extends StatefulWidget {
  const MemberDataEntryPage({super.key});

  @override
  State<MemberDataEntryPage> createState() => _MemberDataEntryPageState();
}

class _MemberDataEntryPageState extends State<MemberDataEntryPage> {
  final _midibApi = MidibApi();
  final _memberApi = MembersApi();

  String? _selectedMidibId;
  String? _selectedMemberId;
  List<Midib> _midibs = [];
  List<Member> _members = [];

  bool _isLoadingMidibs = true;
  bool _isLoadingMembers = false;
  bool _hasMidibError = false;
  bool _hasMemberError = false;

  @override
  void initState() {
    super.initState();
    _loadMidibs();
  }

  Future<void> _loadMidibs() async {
    setState(() {
      _isLoadingMidibs = true;
      _hasMidibError = false;
    });
    try {
      final data = await _midibApi.listMidibs();
      setState(() => _midibs = data);
    } catch (e) {
      debugPrint('Error loading midibs: $e');
      setState(() => _hasMidibError = true);
    } finally {
      setState(() => _isLoadingMidibs = false);
    }
  }

  Future<void> _loadMembers(Midib midib) async {
    setState(() {
      _isLoadingMembers = true;
      _hasMemberError = false;
      _selectedMidibId = midib.id;
      _selectedMemberId = null;
      _members = [];
    });

    try {
      final data = await _memberApi.listMembersByMidib(midib);
      data.sort((a, b) => a.name.compareTo(b.name));
      setState(() => _members = data);
    } catch (e) {
      debugPrint('Error loading members: $e');
      setState(() => _hasMemberError = true);
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(), // ✅ Drawer visible everywhere
      appBar: AppBar(title: const Text('ዝርዝር መረጃ ማስገቢያ')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // 🔽 MIDIB DROPDOWN
                if (_isLoadingMidibs)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ))
                else if (_hasMidibError)
                  ErrorView(
                    message:
                        'ምድቦችን መጫን አልተሳካም። እባክዎ ዳግም ይሞክሩ።',
                    onRetry: _loadMidibs,
                  )
                else
                  InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMidibId,
                        hint: const Text('ምድብ ይምረጡ'),
                        icon: Icon(Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary),
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                        items: _midibs
                            .map((m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                    m.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final midib = _midibs.firstWhere(
                                (m) => m.id == val,
                                orElse: () => _midibs.first);
                            _loadMembers(midib);
                          }
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // 🔽 MEMBER DROPDOWN
                if (_hasMemberError)
				  ErrorView(
					message: 'አባላትን መጫን አልተሳካም። እባክዎ ዳግም ይሞክሩ።',
					onRetry: () {
					  if (_selectedMidibId != null) {
						final midib =
							_midibs.firstWhere((m) => m.id == _selectedMidibId);
						_loadMembers(midib);
					  }
					},
				  )
                else if (_members.isNotEmpty)
                  InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMemberId,
                        hint: const Text('አባል ይምረጡ'),
                        icon: Icon(Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary),
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                        items: _members
                            .map((m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                    '${m.name} (${m.memberCode})',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMemberId = val),
                      ),
                    ),
                  )
                else if (!_isLoadingMembers && _selectedMidibId != null && _members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('በዚህ ምድብ ውስጥ አባል የለም።'),
                  ),

                const SizedBox(height: 24),

                // 🧱 QUICK CARDS (after member selection)
                if (_selectedMemberId != null) ...[
                  _quickCard(context, 'መሠረታዊ መረጃ', Icons.info_outline,
					  '/member_basic_info_entry/${_selectedMemberId!}'),
                  _quickCard(context, 'አድራሻ', Icons.home_outlined,
                      '/member_address_info_entry/${_selectedMemberId!}'),
                  _quickCard(context, 'ሥራ/ትምህርት', Icons.work_outline,
                      '/member_education_and_job_info_entry/${_selectedMemberId!}'),
                  _quickCard(context, 'ቤተሰብ', Icons.family_restroom,
                      '/member_family_info_entry/${_selectedMemberId!}'),
                  _quickCard(context, 'ፎቶ', Icons.photo_camera_outlined,
                      '/member_photo_entry/${_selectedMemberId!}'),
                  _quickCard(context, 'አገልግሎት', Icons.church_outlined,
                      '/member_ministry_info_entry/${_selectedMemberId!}'),
                ],
              ],
            ),
          ),

          // 🔄 Global overlay loader for better UX
          if (_isLoadingMembers)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _quickCard(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Theme.of(context).primaryColor),
        title: Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}