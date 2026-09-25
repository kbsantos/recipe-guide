import 'package:flutter/material.dart';

import '../../../models/menu_category.dart';
import '../../../core/config/category_config.dart';
import '../layout/app_card.dart';

class CategoryHeader extends StatelessWidget {
  final MenuCategory category;

  const CategoryHeader({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: CategoryConfig.color(
              category.type,
            ).withValues(alpha: .15),
            child: Icon(
              CategoryConfig.icon(category.type),
              size: 36,
              color: CategoryConfig.color(category.type),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            category.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(category.subtitle, textAlign: TextAlign.center),

          const SizedBox(height: 12),

          Chip(
            avatar: const Icon(Icons.local_drink),
            label: Text('${category.drinkCount} Drinks'),
          ),
        ],
      ),
    );
  }
}
