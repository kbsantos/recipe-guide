import 'package:flutter/material.dart';

import 'package:recipe_guide/core/config/app_settings.dart';
import 'package:recipe_guide/core/navigation/app_router.dart';

import 'package:recipe_guide/features/favorites/favorites_page.dart';
import 'package:recipe_guide/features/menu/product_list_page.dart';
import 'package:recipe_guide/features/settings/settings_page.dart';

import 'package:recipe_guide/services/store_recipe_sync_service.dart';

import 'package:recipe_guide/shared/widgets/base_page.dart';
import 'package:recipe_guide/services/store_display_catalog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _catalogRefresh = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsService.instance.notifier,
      builder: (context, settings, _) {
        final subtitle = settings.storeName.isEmpty
            ? settings.subtitle
            : '${settings.subtitle} • ${settings.storeName}';
        return BasePage(
          title: settings.title,
          subtitle: subtitle,

          // ========================================================
          // TOP RIGHT ACTIONS
          // ========================================================
          actions: [
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
            // SYNC
            // ------------------------------------------------------
            IconButton(
              tooltip: 'Sync recipes from Store',
              icon: const Icon(Icons.sync),
              onPressed: () async {
                try {
                  await const StoreRecipeSyncService().sync();
                  if (context.mounted) {
                    setState(() => _catalogRefresh++);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipes synced from Store Management.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sync failed: ${e.toString().replaceFirst('Bad state: ', '')} Cached recipes remain available.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            // ------------------------------------------------------
            // SETTINGS
            // ------------------------------------------------------
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () {
                AppRouter.push(context, const SettingsPage());
              },
            ),

            // ------------------------------------------------------
            // LOGOUT
            // ------------------------------------------------------
            if (widget.onLogout != null)
              IconButton(
                tooltip: 'Log out',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Log out?'),
                      content: const Text(
                        'This will lock Recipe Guide. Your saved recipes and Store credentials will remain on this device.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await widget.onLogout!();
                  }
                },
              ),
          ],

          // ========================================================
          // HOME CONTENT
          // ========================================================
          //
          // ========================================================
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: FutureBuilder<List<StoreDisplayProduct>>(
                  future: StoreDisplayProduct.loadProducts(),
                  builder: (context, snapshot) {
                    final products =
                        snapshot.data ?? const <StoreDisplayProduct>[];
                    final query = _searchQuery.trim().toLowerCase();
                    final filteredCount = query.isEmpty
                        ? products.length
                        : products
                              .where(
                                (product) => product.matchesSearchQuery(query),
                              )
                              .length;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search product or category',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$filteredCount products'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: ProductListContent(
                  key: ValueKey('product-$_catalogRefresh'),
                  searchQuery: _searchQuery,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
