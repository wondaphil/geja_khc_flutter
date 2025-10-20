import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../../app/widgets/app_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.I;
    return Scaffold(
      drawer: const AppDrawer(), // keep hamburger menu
      appBar: AppBar(title: const Text('መቼቶች')),
      body: AnimatedBuilder(
        animation: config,
        builder: (context, _) {
          final base = config.baseUrl ?? '';
		  final shortHandUrl = base.length > 13 ? '${base.substring(0, 13)}…' : base;

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _SettingTile(
                icon: Icons.cloud,
                title: 'የሰርቨር አድራሻ',
                subtitle: shortHandUrl,
                onTap: () => context.push('/settings/server'),
              ),
              // Add more tiles later...
            ],
          );
        },
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
