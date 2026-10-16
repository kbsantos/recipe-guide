import 'package:my_shop_recipe_guide/core/navigation/app_router.dart';
import 'package:my_shop_recipe_guide/features/menu/recipe_page.dart';
import 'package:my_shop_recipe_guide/models/menu_item.dart';
import 'package:my_shop_recipe_guide/repositories/menu_repository.dart';
import 'package:my_shop_recipe_guide/services/favorite_service.dart';
import 'package:my_shop_recipe_guide/shared/widgets/base_page.dart';
import 'package:my_shop_recipe_guide/shared/widgets/layout/app_loading.dart';
import 'package:my_shop_recipe_guide/shared/widgets/layout/empty_state.dart';
import 'package:my_shop_recipe_guide/shared/widgets/menu/drink_card.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, this.favoriteService});

  final FavoriteService? favoriteService;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoriteService _favoriteService;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _favoriteService = widget.favoriteService ?? FavoriteService.instance;
    _loadFuture = _favoriteService.load();
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
      title: 'Favorites',
      subtitle: 'Your frequently used drinks',
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(label: 'Loading favorites...');
          }

          final items = _favoriteItems();
          if (items.isEmpty) {
            return const EmptyState(
              title: 'No favorite drinks yet.',
              icon: Icons.favorite_border,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return DrinkCard(
                title: item.title,
                subtitle: 'Favorite recipe',
                isFavorite: true,
                imagePath: item.imagePath,
                trailing: IconButton(
                  tooltip: 'Remove favorite',
                  icon: const Icon(Icons.favorite),
                  onPressed: () => _favoriteService.toggle(item.recipePath),
                ),
                onTap: () => AppRouter.push(
                  context,
                  RecipePage(
                    recipePath: item.recipePath,
                    imagePath: item.imagePath,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<MenuItem> _favoriteItems() {
    final paths = _favoriteService.favoriteRecipePaths;
    return MenuRepository.categories
        .expand((category) => category.groups)
        .expand((group) => group.items)
        .where((item) => paths.contains(item.recipePath))
        .toList(growable: false);
  }
}
