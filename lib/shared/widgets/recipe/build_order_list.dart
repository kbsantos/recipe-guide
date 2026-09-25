import 'package:flutter/material.dart';

import '../layout/empty_state.dart';

import 'step_card.dart';

class BuildOrderList extends StatelessWidget {
  final List<String> steps;

  const BuildOrderList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const EmptyState(
        title: 'No preparation steps are available.',
        icon: Icons.format_list_numbered,
      );
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        return StepCard(stepNumber: entry.key + 1, instruction: entry.value);
      }).toList(),
    );
  }
}
