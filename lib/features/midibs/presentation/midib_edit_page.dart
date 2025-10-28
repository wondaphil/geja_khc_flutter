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
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _pastor = TextEditingController();
  final _remark = TextEditingController();
  final api = MidibApi();

  bool _loading = false;
  bool _saving = false;
  bool _modified = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName;
    _code.text = widget.initialCode;
    _pastor.text = widget.initialPastor ?? '';
    _remark.text = widget.initialRemark ?? '';
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
      // keep prefilled values
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'አስፈላጊ ነው' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ምድብ ተስተካክሏል!')),
      );
      context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('መረጃ ማስቀመጥ አልተሳካም። $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ምድብ ማስተካከያ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () => _modified = true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading) const LinearProgressIndicator(),
                  const SizedBox(height: 8),

                  _textField(
                    label: 'ምድብ ስም *',
                    controller: _name,
                    validator: _req,
                  ),
                  const SizedBox(height: 12),

                  _textField(
                    label: 'መለያ ኮድ *',
                    controller: _code,
                    validator: _req,
                  ),
                  const SizedBox(height: 12),

                  _textField(
                    label: 'የምድብ ተጠሪ',
                    controller: _pastor,
                  ),
                  const SizedBox(height: 12),

                  _textField(
                    label: 'ማስታወሻ',
                    controller: _remark,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          if (_saving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'በማስቀመጥ ላይ...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}