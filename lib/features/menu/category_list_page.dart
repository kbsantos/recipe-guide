import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/config/category_config.dart';

import '../../models/menu_category.dart';
import '../../models/menu_group.dart';

import '../../shared/widgets/base_page.dart';
import '../../shared/widgets/menu/category_card.dart';

import 'drink_list_page.dart';

class CategoryListPage extends StatelessWidget {
  final MenuCategory category;

  const CategoryListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: category.title,
      subtitle: 'Select a menu group',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: category.groups.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final MenuGroup group = category.groups[index];

          return CategoryCard(
            title: group.title,
            subtitle: '${group.items.length} Drinks',

            icon: CategoryConfig.icon(category.type),
            color: CategoryConfig.color(category.type),

            drinkCount: group.items.length,

            onTap: () {
              AppRouter.push(
                context,
                DrinkListPage(category: category, group: group),
              );
            },
          );
        },
      ),
    );
  }
}
