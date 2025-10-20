import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/midib_api.dart';

class MidibDetailPage extends StatelessWidget {
  final String id;
  final String name;
  final String code;
  final String? pastor;
  final String? remark;

  MidibDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.code,
    this.pastor,
    this.remark,
  });

  // Keep an API client handy
  final _api = MidibApi();

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      // keep your original call shape (id/name/code) to satisfy your backend’s binder
      await _api.deleteMidib(id: id, name: name, midibCode: code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ምድቡ በትክክል ተሰርዟል'), duration: Duration(seconds: 3)),
      );
      // Go back and signal that the list should refresh.
      context.pop(true);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e.toString().contains('400')
          ? 'ምድቡ ከአባል መረጃ ጋር ስለተሳሰረ መሰረዝ አልተቻለም!'
          : 'መሰረዝ አልተሳካም። እባክዎ እንደገና ይሞክሩ።';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = name.trim().isEmpty ? 'ምድብ' : name;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'መምረጫ',
            onSelected: (v) {
              if (v == 'delete') _confirmAndDelete(context);
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

      // Primary action (Edit) as FAB
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: const Text('አስተካክል'),
        onPressed: () => context.push(
          '/midibs/$id/edit'
          '?name=${Uri.encodeComponent(name)}'
          '&code=${Uri.encodeComponent(code)}'
          '&pastor=${Uri.encodeComponent(pastor ?? '')}'
          '&remark=${Uri.encodeComponent(remark ?? '')}',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('መለያ ኮድ'), subtitle: Text(code)),
          if ((pastor ?? '').trim().isNotEmpty)
            ListTile(title: const Text('የምድቡ ተጠሪ'), subtitle: Text(pastor!)),
          if ((remark ?? '').trim().isNotEmpty)
            ListTile(title: const Text('ማብራሪያ'), subtitle: Text(remark!)),
        ],
      ),
    );
  }
}
