import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const brandCyan = Color(0xFF00ADEF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ስለ መተግበሪያው')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'የአባላት መረጃ አስተዳደር',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Geja Kale Hiwot Church',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
				color: brandCyan, 
			  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Members Management System',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Column(
				  crossAxisAlignment: CrossAxisAlignment.start,
				  children: [
					const Text('1.0.0'),
					Text('© 2025'), // Copyright symbol
				  ],
				),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
