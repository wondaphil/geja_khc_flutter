import 'package:flutter/material.dart';
import '../../../app/widgets/app_drawer.dart';
import '../../../app/widgets/error_view.dart';
import '../data/reports_api.dart';

class MemberCountByParametersPage extends StatefulWidget {
  const MemberCountByParametersPage({super.key});

  @override
  State<MemberCountByParametersPage> createState() =>
      _MemberCountByParametersPageState();
}

class _MemberCountByParametersPageState
    extends State<MemberCountByParametersPage> {
  final _api = ReportsApi();
  MemberCountKind _selected = MemberCountKind.byMidib;
  Future<List<Map<String, dynamic>>>? _future;

  final ScrollController _horizontal = ScrollController();
  final ScrollController _vertical = ScrollController();

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetch() => _api.fetchMemberCount(_selected);

  void _select(MemberCountKind k) {
    setState(() {
      _selected = k;
      _future = _fetch();
    });
  }

  // ==== Labels ====

  String _chipLabel(MemberCountKind k) {
    switch (k) {
      case MemberCountKind.byGender:
        return 'በፆታ';
      case MemberCountKind.byMidib:
        return 'በምድብ';
      case MemberCountKind.bySubcity:
        return 'በክፍለ ከተማ';
      case MemberCountKind.byHouseOwnershipType:
        return 'በቤት ባለቤትነት';
      case MemberCountKind.byMembershipMeans:
        return 'በአባልነት መንገድ';
      case MemberCountKind.byMembershipYear:
        return 'በአባልነት ዘመን';
      case MemberCountKind.byMaritalStatus:
        return 'በጋብቻ ሁኔታ';
      case MemberCountKind.byEducationLevel:
        return 'በትምህርት ደረጃ';
      case MemberCountKind.byFieldOfStudy:
        return 'በትምህርት መስክ';
      case MemberCountKind.byJob:
        return 'በሥራ ዘርፍ';
      case MemberCountKind.byJobType:
        return 'በሥራ ዓይነት';
      case MemberCountKind.byMinistryCurrent:
        return 'በአገልግሎት';
      case MemberCountKind.byMinistryPrevious:
        return 'በአገልግሎት (የቀድሞ)';
    }
  }

  String _columnTitle(MemberCountKind k) {
    switch (k) {
      case MemberCountKind.byMidib:
        return 'ምድብ';
      case MemberCountKind.byMembershipMeans:
        return 'የአባልነት መንገድ';
      case MemberCountKind.byMembershipYear:
        return 'የአባልነት ዘመን';
      case MemberCountKind.byMinistryCurrent:
      case MemberCountKind.byMinistryPrevious:
        return 'የአገልግሎት ዘርፍ';
      case MemberCountKind.byGender:
        return 'ፆታ';
      case MemberCountKind.byMaritalStatus:
        return 'የጋብቻ ሁኔታ';
      case MemberCountKind.byEducationLevel:
        return 'የትምህርት ደረጃ';
      case MemberCountKind.byFieldOfStudy:
        return 'የትምህርት መስክ';
      case MemberCountKind.byJob:
        return 'የሥራ ዘርፍ';
      case MemberCountKind.byJobType:
        return 'የሥራ ዓይነት';
      case MemberCountKind.bySubcity:
        return 'ክፍለ ከተማ';
      case MemberCountKind.byHouseOwnershipType:
        return 'የቤት ባለቤትነት';
      default:
        return '';
    }
  }

  // ==== Build UI ====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('የአባላት ብዛት በተለያየ መስፈርት'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // --- Choice Chips Bar ---
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: MemberCountKind.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final k = MemberCountKind.values[i];
                return ChoiceChip(
                  label: Text(_chipLabel(k)),
                  selected: _selected == k,
                  onSelected: (_) => _select(k),
                );
              },
            ),
          ),

          // --- Table Data ---
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ✅ Handle network or backend errors gracefully
                if (snap.hasError) {
                  return ErrorView(
                    message:
                        '⚠️ መረጃ መጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
                    onRetry: () => setState(() => _future = _fetch()),
                  );
                }

                final rows = snap.data ?? [];
                if (rows.isEmpty) {
                  return const Center(child: Text('ውጤት አልተገኘም'));
                }

                // Detect object vs string key
                final firstRow = rows.first;
                final firstValue = firstRow.values.first;
                final hasObject = firstValue is Map<String, dynamic>;

                return Scrollbar(
                  controller: _vertical,
                  thumbVisibility: true,
                  child: Scrollbar(
                    controller: _horizontal,
                    thumbVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 1,
                    child: SingleChildScrollView(
                      controller: _vertical,
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        controller: _horizontal,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(12),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                _columnTitle(_selected),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'የአባላት ብዛት',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: rows.map((r) {
                            String label = '—';
                            int count = 0;

                            if (hasObject) {
                              final obj = r.values.first as Map<String, dynamic>;
                              label = obj['name'] ??
                                  obj['midibCode'] ??
                                  obj['id'] ??
                                  '—';
                            } else {
                              final key = r.keys
                                  .firstWhere((k) => k != 'memberCount');
                              label = r[key]?.toString() ?? '—';
                            }
                            count = r['memberCount'] ?? 0;

                            return DataRow(
                              cells: [
                                DataCell(Text(label)),
                                DataCell(Text(count.toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}