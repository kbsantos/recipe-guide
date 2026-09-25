import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
