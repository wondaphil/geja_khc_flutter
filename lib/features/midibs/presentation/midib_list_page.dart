import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/widgets/app_drawer.dart';
import '../data/midib.dart';
import '../data/midib_api.dart';
import '../../../../app/widgets/error_view.dart';

class MidibListPage extends StatefulWidget {
  const MidibListPage({super.key});

  @override
  State<MidibListPage> createState() => _MidibListPageState();
}

class _MidibListPageState extends State<MidibListPage> {
  final api = MidibApi();
  late Future<List<Midib>> future;

  @override
  void initState() {
    super.initState();
    future = api.listMidibs();
  }

  Future<void> _refresh() async {
    setState(() {
      future = api.listMidibs();
    });
  }

  Future<void> _createNew() async {
    final result = await context.push('/midibs/new');
    if (result == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _openDetail(Midib m) async {
    final result = await context.push(
      '/midibs/${Uri.encodeComponent(m.id)}'
      '?name=${Uri.encodeComponent(m.name)}'
      '&code=${Uri.encodeComponent(m.midibCode)}'
      '&pastor=${Uri.encodeComponent(m.pastor ?? "")}'
      '&remark=${Uri.encodeComponent(m.remark ?? "")}',
    );

    // 🔄 Auto-refresh if something was changed in the detail/edit page
    if (result == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('ምድቦች'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'እንደገና መጫን',
            onPressed: _refresh,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.add),
        label: const Text('አዲስ ምድብ'),
      ),

      body: FutureBuilder<List<Midib>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return ErrorView(
              message:
                  '⚠️ ከሰርቭሩ ጋር መገናኘትና መረጃ ማምጣት አልተቻለም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
              onRetry: _refresh,
            );
          }

          final items = (snap.data ?? [])
            ..sort((a, b) => a.name.compareTo(b.name));

          if (items.isEmpty) {
            return const Center(child: Text('ምንም ምድብ አልተገኘም'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = items[i];
                return ListTile(
                  title: Text(
                    m.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(m.midibCode),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDetail(m),
                );
              },
            ),
          );
        },
      ),
    );
  }
}