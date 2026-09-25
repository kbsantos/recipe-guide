import 'package:bigger_brew_barista/shared/widgets/layout/app_card.dart';
import 'package:flutter/material.dart';

class StepCard extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: Text(
              '$stepNumber',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
