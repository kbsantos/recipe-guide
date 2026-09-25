import 'package:flutter/material.dart';

import 'package:bigger_brew_barista/models/recipe.dart';

class RecipeHeader extends StatelessWidget {
  final Recipe recipe;
  final String? imagePath;

  const RecipeHeader({super.key, required this.recipe, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // --------------------------------------------------
            // RECIPE ICON / IMAGE
            // --------------------------------------------------
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePath != null && imagePath!.isNotEmpty
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_cafe_outlined,
                          size: 36,
                          color: theme.colorScheme.onPrimaryContainer,
                        );
                      },
                    )
                  : Icon(
                      Icons.local_cafe_outlined,
                      size: 36,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
            ),

            const SizedBox(width: 18),

            // --------------------------------------------------
            // TITLE + CATEGORY
            // --------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final category = recipe.category.trim();

    if (category.isNotEmpty) {
      return category;
    }

    return 'Recipe';
  }
}
