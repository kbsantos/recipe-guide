import 'package:bigger_brew_barista/models/recipe_size.dart';
import 'package:flutter/material.dart';

class RecipeSizeSelector extends StatelessWidget {
  final List<RecipeSize> sizes;
  final RecipeSize selectedSize;
  final ValueChanged<RecipeSize> onSelected;

  const RecipeSizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sizes.map((size) {
        final selected = size.size == selectedSize.size;

        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onSelected(size),

          // Larger touch target for counter use.
          labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),

          avatar: selected ? const Icon(Icons.check, size: 18) : null,

          label: Text(
            size.size,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),

          selectedColor: theme.colorScheme.primaryContainer,

          backgroundColor: theme.colorScheme.surface,

          side: BorderSide(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
