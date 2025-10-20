import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/midib.dart';
import '../data/midib_api.dart';

class MidibEditPage extends StatefulWidget {
  final String id;
  final String initialName;
  final String initialCode;
  final String? initialPastor;
  final String? initialRemark;

  const MidibEditPage({
    super.key,
    required this.id,
    required this.initialName,
    required this.initialCode,
    this.initialPastor,
    this.initialRemark,
  });

  @override
  State<MidibEditPage> createState() => _MidibEditPageState();
}

class _MidibEditPageState extends State<MidibEditPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _pastor = TextEditingController();
  final _remark = TextEditingController();
  final api = MidibApi();

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Prefill immediately
    _name.text = widget.initialName;
    _code.text = widget.initialCode;
    _pastor.text = widget.initialPastor ?? '';
    _remark.text = widget.initialRemark ?? '';
    // Fetch fresh from server as fail-safe
    _loadFresh();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _pastor.dispose();
    _remark.dispose();
    super.dispose();
  }

  Future<void> _loadFresh() async {
    setState(() => _loading = true);
    try {
      final m = await api.getMidibForEdit(
        id: widget.id,
        name: _name.text,
        midibCode: _code.text,
      );
      if (!mounted) return;
      _name.text = m.name;
      _code.text = m.midibCode;
      _pastor.text = m.pastor ?? '';
      _remark.text = m.remark ?? '';
    } catch (_) {
      // keep prefilled values if server rejects
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('ምድብ ማስተካከያ')),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'ምድብ'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(controller: _code, decoration: const InputDecoration(labelText: 'መለያ ኮድ'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(controller: _pastor, decoration: const InputDecoration(labelText: 'የምድቡ ተጠሪ')),
              const SizedBox(height: 12),
              TextFormField(controller: _remark, decoration: const InputDecoration(labelText: 'ማብራሪያ'), maxLines: 2),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await api.setMidib(
        Midib(
          id: widget.id,
          name: _name.text.trim(),
          midibCode: _code.text.trim(),
          pastor: _pastor.text.trim().isEmpty ? null : _pastor.text.trim(),
          remark: _remark.text.trim().isEmpty ? null : _remark.text.trim(),
        ),
      );
      if (mounted) context.go('/midibs');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
