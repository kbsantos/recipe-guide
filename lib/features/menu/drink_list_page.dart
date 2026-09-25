import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';

import '../../models/menu_category.dart';
import '../../models/menu_group.dart';
import '../../services/favorite_service.dart';

import '../../shared/widgets/base_page.dart';
import '../../shared/widgets/layout/empty_state.dart';

import '../../shared/widgets/menu/drink_card.dart';

import 'recipe_page.dart';

class DrinkListPage extends StatefulWidget {
  final MenuCategory category;
  final MenuGroup group;

  const DrinkListPage({super.key, required this.category, required this.group});

  @override
  State<DrinkListPage> createState() => _DrinkListPageState();
}

class _DrinkListPageState extends State<DrinkListPage> {
  final _favoriteService = FavoriteService.instance;

  @override
  void initState() {
    super.initState();

    _favoriteService.load();
    _favoriteService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: widget.group.title,
      subtitle: '${widget.group.items.length} Drinks',
      child: _buildDrinkList(),
    );
  }

  Widget _buildDrinkList() {
    if (widget.group.items.isEmpty) {
      return const EmptyState(
        title: 'No drinks available.',
        icon: Icons.local_cafe,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: widget.group.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final drink = widget.group.items[index];

        return DrinkCard(
          title: drink.title,
          subtitle: 'Recipe Available',
          imagePath: drink.imagePath,
          isFavorite: _favoriteService.isFavorite(drink.recipePath),
          onTap: () async {
            await AppRouter.push(
              context,
              RecipePage(
                recipePath: drink.recipePath,
                imagePath: drink.imagePath,
              ),
            );

            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}
