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
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _pastor = TextEditingController();
  final _remark = TextEditingController();
  final api = MidibApi();
  bool _saving = false;
  bool _modified = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _pastor.dispose();
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('አዲስ ምድብ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: () => _modified = true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'አስፈላጊ ነው' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final m = Midib(
        id: '',
        name: _name.text.trim(),
        midibCode: _code.text.trim(),
        pastor: _pastor.text.trim().isEmpty ? null : _pastor.text.trim(),
        remark: _remark.text.trim().isEmpty ? null : _remark.text.trim(),
      );
      await api.setMidib(m);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ምድብ ተቀምጧል!')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('መረጃ ማስቀመጥ አልተሳካም። $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}