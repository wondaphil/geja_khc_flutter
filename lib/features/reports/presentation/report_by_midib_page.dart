import 'package:flutter/material.dart';
import '../../midibs/data/midib.dart'; // if you want to reuse labels later
import '../data/reports_api.dart';
import '../../../app/widgets/app_drawer.dart';

class ReportsByMidibPage extends StatefulWidget {
  const ReportsByMidibPage({super.key});

  @override
  State<ReportsByMidibPage> createState() => _ReportsByMidibPageState();
}

class _ReportsByMidibPageState extends State<ReportsByMidibPage> {
  final _api = ReportsApi();

  // Default to Gender (common & clear)
  ReportKind _kind = ReportKind.gender;
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetch(_kind);
  }

  void _select(ReportKind k) {
    if (_kind == k) return;
    setState(() {
      _kind = k;
      _future = _api.fetch(_kind);
    });
  }

  // Amharic labels for chips
  String _chipLabel(ReportKind k) {
    switch (k) {
      case ReportKind.educationLevel:  return 'በትምህርት ደረጃ';
      case ReportKind.maritalStatus:   return 'በጋብቻ ሁኔታ';
      case ReportKind.membershipMeans: return 'በአባልነት መንገድ';
      case ReportKind.subcity:         return 'በክፍለ-ከተማ';
      case ReportKind.gender:          return 'በፆታ';
    }
  }

  // Pretty header mapping for common columns
  static const _pretty = <String, String>{
    'midibName': 'ምድብ',
    'total': 'ጠቅላላ',
    'male': 'ወንድ',
    'female': 'ሴት',
    // You can extend with: 'single': 'ነጭ', 'married': 'ታማጭ', etc. based on the endpoint payloads
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // keep hamburger menu
      appBar: AppBar(title: const Text('የአባላት ብዛት በምድብ')),
      body: Column(
        children: [
          // ===== ChoiceChips bar (scrollable) =====
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                final k = ReportKind.values[i];
                final selected = _kind == k;
                return ChoiceChip(
                  label: Text(_chipLabel(k)),
                  selected: selected,
                  onSelected: (_) => _select(k),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: ReportKind.values.length,
            ),
          ),

          // ===== Results =====
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _api.fetch(_kind));
                await _future;
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Error: ${snap.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  final rows = snap.data ?? const [];

                  if (rows.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('ውጤት አልተገኘም')),
                      ],
                    );
                  }

                  // Build a stable, readable column order:
                  // 1) Always show midibName first if present
                  // 2) Then total if present
                  // 3) Then other numeric/string keys (except obvious ids)
                  final allKeys = <String>{};
                  for (final r in rows) {
                    allKeys.addAll(r.keys);
                  }
                  // Filter technical keys
                  final tech = {'rowId', 'midibId'};
                  final keys = allKeys.where((k) => !tech.contains(k)).toList();

                  // Sort columns with our preferred order
                  keys.sort((a, b) {
                    int score(String k) {
                      if (k == 'midibName') return 0;
                      if (k == 'total') return 1;
                      return 2;
                    }
                    final s = score(a).compareTo(score(b));
                    if (s != 0) return s;
                    return a.compareTo(b);
                  });

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 24,
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          columns: keys.map((k) {
                            final label = _pretty[k] ?? k;
                            return DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));
                          }).toList(),
                          rows: rows.map((r) {
                            return DataRow(
                              cells: keys.map((k) {
                                final v = r[k];
                                final text = (v == null) ? '' : v.toString();
                                return DataCell(Text(text));
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}