import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/widgets/app_drawer.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Widget _quickCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(route),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('ሪፖርቶች')),
      body: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          _quickCard(
            context,
            'የአባላት ብዛት በምድብ',
            Icons.groups_2_rounded,
            '/reports/by-midib',
          ),
          _quickCard(
            context,
            'የአባላት ብዛት በተለያየ መስፈርት',
            Icons.bar_chart_rounded,
            '/reports/by-parameters',
          ),
        ],
      ),
    );
  }
}