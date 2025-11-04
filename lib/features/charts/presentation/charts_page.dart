import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/charts_api.dart';
import '../../../app/widgets/app_drawer.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final _api = ChartsApi();

  ChartKind _kind = ChartKind.byGender;
  bool _isPie = false; // toggle bar/pie
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getData(_kind);
  }

  void _selectKind(ChartKind k) {
    if (_kind == k) return;
    setState(() {
      _kind = k;
      _future = _api.getData(_kind);
    });
  }

  String _label(ChartKind k) {
    switch (k) {
      case ChartKind.byGender:          return 'በፆታ';
      case ChartKind.byMidib:           return 'በምድብ';
      case ChartKind.byEducationLevel:  return 'በትምህርት ደረጃ';
      case ChartKind.byMaritalStatus:   return 'በጋብቻ ሁኔታ';
      case ChartKind.byMembershipMeans: return 'በአባልነት መንገድ';
      case ChartKind.byMembershipYear:  return 'በአባልነት ዘመን';
      case ChartKind.bySubcity:         return 'በክፍለ ከተማ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = const Color(0xFF00ADEF);

    return Scaffold(
      drawer: const AppDrawer(), // keep hamburger menu
      appBar: AppBar(
        title: const Text('የአባላት ብዛት ቻርት'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text('Bar'),
                Switch(
                  value: _isPie,
                  onChanged: (v) => setState(() => _isPie = v),
                  activeColor: brand,
                ),
                const Text('Pie'),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: ChartKind.values.length,
              itemBuilder: (_, i) {
                final k = ChartKind.values[i];
                return ChoiceChip(
                  label: Text(_label(k)),
                  selected: _kind == k,
                  onSelected: (_) => _selectKind(k),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
            ),
          ),

          // chart area
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }
                final data = snap.data ?? const [];
                if (data.isEmpty) {
                  return const Center(child: Text('ውጤት አልተገኘም'));
                }

                // normalize to entries
                final entries = data
                    .map((e) => _ChartEntry(
                          label: e['label'].toString(),
                          value: (e['count'] as num).toDouble(),
                        ))
                    .toList();

                if (_isPie) {
                  return _PieChartView(entries: entries);
                } else {
                  return _BarChartView(entries: entries);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartEntry {
  final String label;
  final double value;
  _ChartEntry({required this.label, required this.value});
}

/// ===== Pie chart =====
class _PieChartView extends StatelessWidget {
  final List<_ChartEntry> entries;
  const _PieChartView({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('የሚታይ መረጃ የለም'));
    }

    final total = entries.fold<double>(0, (p, e) => p + e.value);
    final sections = <PieChartSectionData>[
      for (int i = 0; i < entries.length; i++)
        PieChartSectionData(
          value: entries[i].value,
          title: total > 0 ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%' : '',
          radius: 70,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          color: _palette[i % _palette.length],
          badgeWidget: null,
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
    ];

    final chart = AspectRatio(
      aspectRatio: 16 / 11,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 1,
          centerSpaceRadius: 42,
        ),
      ),
    );

    // Legend
    final legend = Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < entries.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: _palette[i % _palette.length], borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(
                entries[i].label.length > 16 ? '${entries[i].label.substring(0, 16)}…' : entries[i].label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            chart,
            const SizedBox(height: 8),
            legend,
          ],
        ),
      ),
    );
  }
}

// Pleasant, restrained palette
const List<Color> _palette = [
  Color(0xFF00ADEF),
  Color(0xFF4DD0E1),
  Color(0xFF0097A7),
  Color(0xFF80DEEA),
  Color(0xFF26C6DA),
  Color(0xFF00BCD4),
  Color(0xFF5BD7FF),
];

/// ===== Bar chart =====
class _BarChartView extends StatelessWidget {
  final List<_ChartEntry> entries;
  const _BarChartView({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('የሚታይ መረጃ የለም'));
    }

    final maxVal = entries.fold<double>(0, (p, e) => e.value > p ? e.value : p);
    final maxY = (maxVal * 1.18).clamp(1.0, double.infinity);
    final count = entries.length;
    final needsScroll = count > 12;
    final textStyle = Theme.of(context).textTheme.bodySmall;

    // Soft, muted spectrum — not neon
    final spectrumColors = [
      const Color(0xFFD32F2F), // red
      const Color(0xFFF57C00), // deep orange
      const Color(0xFFFBC02D), // amber
      const Color(0xFFAFB42B), // olive green
      const Color(0xFF388E3C), // green
      const Color(0xFF00796B), // teal
      const Color(0xFF0288D1), // blue
      const Color(0xFF303F9F), // indigo
      const Color(0xFF7B1FA2), // purple
      const Color(0xFFC2185B), // pink
      const Color(0xFF8D6E63), // brown
      const Color(0xFF757575), // gray
    ];

    Widget buildChart(double chartWidth) {
      final alignment =
          needsScroll ? BarChartAlignment.center : BarChartAlignment.spaceBetween;
      final barWidth = needsScroll
          ? (count <= 16 ? 14.0 : 12.0)
          : (chartWidth / (count * 2.4)).clamp(16.0, 36.0);

      return BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: alignment,
          groupsSpace: needsScroll ? 12.0 : 0.0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 200,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.black12,
              strokeWidth: 1.0,
            ),
          ),
          // ✅ Force draw 0-line manually
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: Colors.black12,
                strokeWidth: 1.0,
              ),
            ],
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 200,
                reservedSize: 48,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    v.toInt().toString(),
                    style: textStyle,
                  ),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final i = val.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  final label = entries[i].label;
                  final short =
                      label.length > 10 ? '${label.substring(0, 10)}…' : label;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Transform.rotate(
                      angle: -1.57, // 90° vertical
                      alignment: Alignment.center,
                      child: Text(short, style: textStyle),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = entries[group.x.toInt()].label;
                return BarTooltipItem(
                  '$label\n',
                  const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: rod.toY.toStringAsFixed(0)),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (int i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value,
                    width: barWidth,
                    borderRadius: BorderRadius.zero, // sharp corners
                    color: spectrumColors[i % spectrumColors.length],
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // ✅ generous 25% bottom margin to make room for vertical labels
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        child: SizedBox(
          height: 320,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (needsScroll) {
                final contentWidth = (entries.length * 32.0) + 60.0;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                      SizedBox(width: contentWidth, child: buildChart(contentWidth)),
                );
              }
              return buildChart(constraints.maxWidth);
            },
          ),
        ),
      ),
    );
  }
}