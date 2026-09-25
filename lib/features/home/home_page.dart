import 'package:flutter/material.dart';

import 'package:bigger_brew_barista/core/config/app_constants.dart';
import 'package:bigger_brew_barista/core/config/category_config.dart';
import 'package:bigger_brew_barista/core/navigation/app_router.dart';

import 'package:bigger_brew_barista/features/favorites/favorites_page.dart';
import 'package:bigger_brew_barista/features/menu/category_list_page.dart';
import 'package:bigger_brew_barista/features/recent/recent_drinks_page.dart';
import 'package:bigger_brew_barista/features/search/search_page.dart';

import 'package:bigger_brew_barista/repositories/menu_repository.dart';

import 'package:bigger_brew_barista/shared/widgets/base_page.dart';
import 'package:bigger_brew_barista/shared/widgets/menu/category_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppConstants.appName,
      subtitle: AppConstants.appSubtitle,

      // ========================================================
      // TOP RIGHT ACTIONS
      // ========================================================
      actions: [
        // ------------------------------------------------------
        // RECENT DRINKS
        // ------------------------------------------------------
        IconButton(
          tooltip: 'Recent drinks',
          icon: const Icon(Icons.history),
          onPressed: () {
            AppRouter.push(context, const RecentDrinksPage());
          },
        ),

        // ------------------------------------------------------
        // FAVORITES
        // ------------------------------------------------------
        IconButton(
          tooltip: 'Favorite drinks',
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            AppRouter.push(context, const FavoritesPage());
          },
        ),

        // ------------------------------------------------------
        // SEARCH
        // ------------------------------------------------------
        IconButton(
          tooltip: 'Search drinks',
          icon: const Icon(Icons.search),
          onPressed: () {
            AppRouter.push(context, const SearchPage());
          },
        ),
      ],

      // ========================================================
      // HOME CONTENT
      // ========================================================
      //
      // Recent Drinks is intentionally NOT displayed here.
      //
      // It is available from the history icon above.
      //
      // ========================================================
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          ...MenuRepository.categories.map(
            (category) => CategoryCard(
              title: category.title,
              subtitle: category.subtitle,
              icon: CategoryConfig.icon(category.type),
              color: CategoryConfig.color(category.type),
              drinkCount: category.drinkCount,
              onTap: () {
                AppRouter.push(context, CategoryListPage(category: category));
              },
            ),
          ),
        ],
      ),
    );
  }
}
