import 'package:flutter/material.dart';

import '../layout/app_card.dart';

class DrinkCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Future use
  final bool isFavorite;
  final Widget? trailing;
  final String? imagePath;

  const DrinkCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isFavorite = false,
    this.trailing,
    this.imagePath,
  });

  Widget _placeholder(BuildContext context) {
    return Icon(
      Icons.local_cafe,
      color: Theme.of(context).colorScheme.primary,
      size: 28,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          //----------------------------------------------------------
          // Drink Icon / Image
          //----------------------------------------------------------
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imagePath == null || imagePath!.isEmpty
                ? _placeholder(context)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(context),
                    ),
                  ),
          ),

          const SizedBox(width: 16),

          //----------------------------------------------------------
          // Information
          //----------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                    if (isFavorite)
                      const Icon(Icons.favorite, color: Colors.red, size: 18),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle ?? 'Recipe Available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          //----------------------------------------------------------
          // Trailing
          //----------------------------------------------------------
          trailing ?? const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
