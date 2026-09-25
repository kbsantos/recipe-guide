import 'package:bigger_brew_barista/core/config/ingredient_config.dart';
import 'package:bigger_brew_barista/models/ingredient.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/app_card.dart';
import 'package:flutter/material.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientTile({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final quantity = [
      ingredient.amount,
      ingredient.unit,
    ].where((value) => value.isNotEmpty).join(' ');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: IngredientConfig.color(ingredient.name).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IngredientConfig.icon(ingredient.name),
              color: IngredientConfig.color(ingredient.name),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(ingredient.name)),
          if (quantity.isNotEmpty)
            Text(
              quantity,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
