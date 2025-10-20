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
      _memberCodeCtl.text = ''; // clear old suggestion
      _loadingCode = _selected != null;
    });

    if (_selected != null) {
      try {
        final suggestion = await api.nextMemberCodeForMidib(_selected!);
        if (!mounted) return;
        setState(() {
          _memberCodeCtl.text = suggestion;
        });
      } catch (_) {
        // ignore, leave empty
      } finally {
        if (mounted) setState(() => _loadingCode = false);
      }
    } else {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  Future<void> _save() async {
    if (_selected == null || _nameCtl.text.trim().isEmpty || _memberCodeCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ስም፣ ምድብ እና የአባል ኮድ አስፈላጊ ናቸው')),
      );
      return;
    }
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
        const SnackBar(content: Text('አባል ተሳክቶ ተመዝግቧል')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ማስቀመጥ አልተሳካም: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('አዲስ አባል መመዝገቢያ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtl,
            decoration: const InputDecoration(labelText: 'ስም', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'ምድብ', border: OutlineInputBorder()),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selected?.id.isEmpty == true ? null : _selected?.id,
                hint: const Text('ምድብ ይምረጡ'),
                items: _midibs.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                onChanged: _onMidibChanged,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memberCodeCtl,
            decoration: InputDecoration(
              labelText: 'የአባል ኮድ',
              border: const OutlineInputBorder(),
              suffixIcon: _loadingCode ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ) : null,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('አባል አስቀምጥ'),
          ),
        ],
      ),
    );
  }
}
