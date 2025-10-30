import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/config.dart';
import '../../auth/data/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = makeDio();
      final res = await dio.post(
        '/api/auth/login',
        data: {
          'username': _usernameCtl.text.trim(),
          'password': _passwordCtl.text.trim(),
        },
      );

      final token = res.data['token'] as String?;
      if (token == null) throw Exception('ያልተጠበቀ የሰርቨር ችግር አጋጥሟል');

      // save token
      await TokenStorage.save(token);

      if (!mounted) return;
      context.go('/');
    } on DioException catch (e) {
      setState(() => _error = 'የተሳሳተ የተጠቃሚ ስም ወይም የይለፍ ቃል');
    } catch (e) {
      setState(() => _error = 'የመግባት ሙከራው አልተሳካም: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'ለመቀጠል እባክዎን ወደ አካውንትዎ ይግቡ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 24),

                // Username
                TextFormField(
                  controller: _usernameCtl,
                  decoration: const InputDecoration(
                    labelText: 'የተጠቃሚ ስም',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'ማለፊያ ቃል',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ይግቡ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}