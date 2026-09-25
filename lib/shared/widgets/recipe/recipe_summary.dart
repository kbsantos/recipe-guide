import 'package:bigger_brew_barista/shared/widgets/layout/app_card.dart';
import 'package:flutter/material.dart';

class RecipeSummary extends StatelessWidget {
  final String size;
  final int ingredientCount;
  final int stepCount;

  const RecipeSummary({
    super.key,
    required this.size,
    required this.ingredientCount,
    required this.stepCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(icon: Icons.local_drink, title: size, subtitle: 'Size'),
          _SummaryItem(
            icon: Icons.inventory_2,
            title: '$ingredientCount',
            subtitle: 'Ingredients',
          ),
          _SummaryItem(
            icon: Icons.format_list_numbered,
            title: '$stepCount',
            subtitle: 'Steps',
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
