import 'package:flutter/material.dart';

/// Tela temporária. Cada feature substitui a sua por uma tela real.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
