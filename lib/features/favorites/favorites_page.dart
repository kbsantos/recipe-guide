import 'package:bigger_brew_barista/core/navigation/app_router.dart';
import 'package:bigger_brew_barista/features/menu/recipe_page.dart';
import 'package:bigger_brew_barista/models/menu_item.dart';
import 'package:bigger_brew_barista/repositories/menu_repository.dart';
import 'package:bigger_brew_barista/services/favorite_service.dart';
import 'package:bigger_brew_barista/shared/widgets/base_page.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/app_loading.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/empty_state.dart';
import 'package:bigger_brew_barista/shared/widgets/menu/drink_card.dart';
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
