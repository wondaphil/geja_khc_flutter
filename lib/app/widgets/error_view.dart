import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Split message into two parts by the first "። "
    final parts = message.split('።');
    final firstLine = parts.isNotEmpty ? '${parts.first.trim()}።' : message;
    final secondLine = parts.length > 1 ? parts.sublist(1).join('።').trim() : '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),

            // 🔴 First line (red, bold, larger)
            Text(
              firstLine,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // ⚪ Second line (normal, slightly larger font)
            if (secondLine.isNotEmpty)
              Text(
                secondLine,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 24),

            if (onRetry != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('ደግመህ ሞክር'),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}