import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';

class ServerAddressPage extends StatefulWidget {
  const ServerAddressPage({super.key});

  @override
  State<ServerAddressPage> createState() => _ServerAddressPageState();
}

class _ServerAddressPageState extends State<ServerAddressPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _url;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: AppConfig.I.baseUrl);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Required';
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      return 'Must start with http:// or https://';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await AppConfig.I.setBaseUrl(_url.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    context.pop(); // back to Settings
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('የሰርቨር አድራሻ')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'Server Base URL',
                hintText: 'http://example.com',
              ),
              validator: _validate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
