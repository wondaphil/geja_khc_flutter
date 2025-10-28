import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../midibs/data/midib.dart';
import '../../midibs/data/midib_api.dart';
import '../data/member.dart';
import '../data/members_api.dart';

class MemberNewPage extends StatefulWidget {
  const MemberNewPage({super.key});

  @override
  State<MemberNewPage> createState() => _MemberNewPageState();
}

class _MemberNewPageState extends State<MemberNewPage> {
  final api = MembersApi();
  final midibApi = MidibApi();

  final _nameCtl = TextEditingController();
  final _memberCodeCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Midib> _midibs = [];
  Midib? _selected;
  bool _loadingCode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMidibs();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _memberCodeCtl.dispose();
    super.dispose();
  }

  Future<void> _loadMidibs() async {
    final list = await midibApi.listMidibs();
    list.sort((a, b) => a.name.compareTo(b.name));
    if (!mounted) return;
    setState(() => _midibs = list);
  }

  Future<void> _onMidibChanged(String? id) async {
    final sel = _midibs.firstWhere(
      (m) => m.id == id,
      orElse: () => Midib(id: '', name: '', midibCode: ''),
    );
    setState(() {
      _selected = (id == null || id.isEmpty) ? null : sel;
      _memberCodeCtl.text = '';
      _loadingCode = _selected != null;
    });

    if (_selected != null) {
      try {
        final suggestion = await api.nextMemberCodeForMidib(_selected!);
        if (!mounted) return;
        setState(() => _memberCodeCtl.text = suggestion);
      } catch (_) {
        // ignore
      } finally {
        if (mounted) setState(() => _loadingCode = false);
      }
    } else {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await api.setMember(
        Member(
          id: '',
          name: _nameCtl.text.trim(),
          memberCode: _memberCodeCtl.text.trim(),
          midibId: _selected!.id,
        ).toJson(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('አባል ተመዝግቧል!')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ማስቀመጥ አልተሳካም። $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'አስፈላጊ ነው' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('አዲስ አባል መመዝገቢያ'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField(
                label: 'ስም *',
                controller: _nameCtl,
                validator: _req,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selected?.id.isEmpty == true ? null : _selected?.id,
                decoration: InputDecoration(
                  labelText: 'ምድብ *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'ምድብ ይምረጡ' : null,
                items: _midibs
                    .map((m) =>
                        DropdownMenuItem(value: m.id, child: Text(m.name)))
                    .toList(),
                onChanged: _onMidibChanged,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memberCodeCtl,
                validator: _req,
                decoration: InputDecoration(
                  labelText: 'የአባል ኮድ *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: _loadingCode
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}