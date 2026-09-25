import 'package:bigger_brew_barista/models/ingredient.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/empty_state.dart';
import 'package:flutter/material.dart';

import 'ingredient_tile.dart';

class IngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const EmptyState(
        title: 'No ingredients are available for this size.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return Column(
      children: ingredients
          .map((ingredient) => IngredientTile(ingredient: ingredient))
          .toList(),
    );
  }
}
