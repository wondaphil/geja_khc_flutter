import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/midib.dart';
import '../data/midib_api.dart';

class MidibNewPage extends StatefulWidget {
  const MidibNewPage({super.key});

  @override
  State<MidibNewPage> createState() => _MidibNewPageState();
}

class _MidibNewPageState extends State<MidibNewPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _pastor = TextEditingController();
  final _remark = TextEditingController();
  final api = MidibApi();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('አዲስ ምድብ')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'ስም'), validator: _req),
            TextFormField(controller: _code, decoration: const InputDecoration(labelText: 'መለያ ኮድ'), validator: _req),
            TextFormField(controller: _pastor, decoration: const InputDecoration(labelText: 'የምድብ ተጠሪ')),
            TextFormField(controller: _remark, decoration: const InputDecoration(labelText: 'ማስታወሻ')),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _saving? null : _save, child: const Text('ሴብ አድርግ'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: ()=> context.pop(), child: const Text('ተወው'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _req(String? v) => (v==null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final m = Midib(
        id: '',
        name: _name.text.trim(),
        midibCode: _code.text.trim(),
        pastor: _pastor.text.trim().isEmpty? null : _pastor.text.trim(),
        remark: _remark.text.trim().isEmpty? null : _remark.text.trim(),
      );
      await api.setMidib(m);
      if (mounted) context.go('/midibs');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
