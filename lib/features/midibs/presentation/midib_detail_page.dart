import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/midib_api.dart';
import '../data/midib.dart';

class MidibDetailPage extends StatefulWidget {
  final String id;
  final String name;
  final String code;
  final String? pastor;
  final String? remark;

  const MidibDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.code,
    this.pastor,
    this.remark,
  });

  @override
  State<MidibDetailPage> createState() => _MidibDetailPageState();
}

class _MidibDetailPageState extends State<MidibDetailPage> {
  final _api = MidibApi();
  bool _loading = false;
  Midib? _midib;

  @override
  void initState() {
    super.initState();
    // initialize from passed values for instant UI
    _midib = Midib(
      id: widget.id,
      name: widget.name,
      midibCode: widget.code,
      pastor: widget.pastor,
      remark: widget.remark,
    );
    _loadFresh(); // also fetch from server
  }

  Future<void> _loadFresh() async {
    setState(() => _loading = true);
    try {
      final m = await _api.getMidibForEdit(
        id: widget.id,
        name: widget.name,
        midibCode: widget.code,
      );
      if (!mounted) return;
      setState(() => _midib = m);
    } catch (e) {
      debugPrint('❌ Error refreshing midib: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ማረጋገጫ'),
        content: const Text('ምድቡን ለመሰረዝ እርግጠኛ ነህ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ተወው')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('አዎን')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _api.deleteMidib(id: widget.id, name: widget.name, midibCode: widget.code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ምድቡ በትክክል ተሰርዟል')),
      );
      context.pop(true); // return to list with refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('መሰረዝ አልተሳካም። $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _midib;
    if (m == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(m.name.isEmpty ? 'ምድብ' : m.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFresh,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') _confirmAndDelete();
            },
            itemBuilder: (c) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('ሰርዝ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: const Text('አስተካክል'),
        onPressed: () async {
          final result = await context.push(
            '/midibs/${m.id}/edit'
            '?name=${Uri.encodeComponent(m.name)}'
            '&code=${Uri.encodeComponent(m.midibCode)}'
            '&pastor=${Uri.encodeComponent(m.pastor ?? '')}'
            '&remark=${Uri.encodeComponent(m.remark ?? '')}',
          );
          if (result == true && mounted) {
            await _loadFresh(); // 🔁 refresh after editing
          }
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(title: const Text('መለያ ኮድ'), subtitle: Text(m.midibCode)),
                if ((m.pastor ?? '').trim().isNotEmpty)
                  ListTile(title: const Text('የምድቡ ተጠሪ'), subtitle: Text(m.pastor!)),
                if ((m.remark ?? '').trim().isNotEmpty)
                  ListTile(title: const Text('ማብራሪያ'), subtitle: Text(m.remark!)),
              ],
            ),
    );
  }
}