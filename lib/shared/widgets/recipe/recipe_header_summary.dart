import 'package:flutter/material.dart';

class RecipeHeaderSummary extends StatelessWidget {
  final String title;
  final String category;
  final String group;
  final String size;
  final int ingredientCount;
  final int stepCount;

  final IconData? icon;

  final bool isFavorite;

  final VoidCallback onFavorite;
  final VoidCallback onEdit;
  final VoidCallback onStartPreparation;
  final VoidCallback onCopy;

  final bool canStartPreparation;

  const RecipeHeaderSummary({
    super.key,
    required this.title,
    required this.category,
    required this.group,
    required this.size,
    required this.ingredientCount,
    required this.stepCount,
    required this.isFavorite,
    required this.onFavorite,
    required this.onEdit,
    required this.onStartPreparation,
    required this.onCopy,
    this.canStartPreparation = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ======================================================
            // RECIPE ICON
            // ======================================================
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon ?? Icons.local_cafe,
                color: scheme.primary,
                size: 26,
              ),
            ),

            const SizedBox(width: 12),

            // ======================================================
            // TITLE + CATEGORY
            // ======================================================
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '$category • $group',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ======================================================
            // SUMMARY
            // ======================================================
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      icon: Icons.local_drink_outlined,
                      value: size,
                      label: 'Size',
                    ),
                  ),
                  Expanded(
                    child: _SummaryMetric(
                      icon: Icons.inventory_2_outlined,
                      value: '$ingredientCount',
                      label: 'Ingredients',
                    ),
                  ),
                  Expanded(
                    child: _SummaryMetric(
                      icon: Icons.format_list_numbered,
                      value: '$stepCount',
                      label: 'Steps',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ======================================================
            // TOP-RIGHT ACTION ICONS
            // ======================================================
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderActionButton(
                      tooltip: 'Start Preparation',
                      icon: Icons.play_arrow_rounded,
                      onPressed: canStartPreparation
                          ? onStartPreparation
                          : null,
                    ),

                    _HeaderActionButton(
                      tooltip: isFavorite ? 'Remove Favorite' : 'Add Favorite',
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      onPressed: onFavorite,
                      color: isFavorite ? scheme.error : null,
                    ),

                    _HeaderActionButton(
                      tooltip: 'Copy Recipe',
                      icon: Icons.copy_outlined,
                      onPressed: onCopy,
                    ),

                    _HeaderActionButton(
                      tooltip: 'Edit Recipe',
                      icon: Icons.edit_outlined,
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HEADER ACTION BUTTON
// ================================================================

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      iconSize: 21,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

// ================================================================
// SUMMARY METRIC
// ================================================================

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 21, color: theme.colorScheme.primary),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
