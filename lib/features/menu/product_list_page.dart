import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../services/favorite_service.dart';
import '../../services/store_display_catalog.dart';
import '../../shared/widgets/base_page.dart';
import '../../shared/widgets/layout/app_loading.dart';
import '../../shared/widgets/layout/empty_state.dart';
import '../../shared/widgets/menu/kiosk_product_card.dart';
import 'recipe_page.dart';

class ProductListPage extends StatelessWidget {
  final String? categoryId;
  final String? categoryTitle;
  final String searchQuery;

  const ProductListPage({
    super.key,
    this.categoryId,
    this.categoryTitle,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: categoryTitle ?? 'Products',
      subtitle: categoryTitle == null ? 'All Recipes' : 'Recipes',
      child: ProductListContent(categoryId: categoryId, searchQuery: searchQuery),
    );
  }
}

class ProductListContent extends StatefulWidget {
  final String? categoryId;
  final String searchQuery;

  const ProductListContent({
    super.key,
    this.categoryId,
    this.searchQuery = '',
  });

  @override
  State<ProductListContent> createState() => _ProductListContentState();
}

class _ProductListContentState extends State<ProductListContent> {
  final _favoriteService = FavoriteService.instance;
  late Future<List<StoreDisplayProduct>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _favoriteService.load();
    _favoriteService.addListener(_onFavoritesChanged);
    _productsFuture = _loadProducts();
  }

  @override
  void didUpdateWidget(covariant ProductListContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.searchQuery != widget.searchQuery) {
      setState(() {
        _productsFuture = _loadProducts();
      });
    }
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<List<StoreDisplayProduct>> _loadProducts() async {
    final products = await StoreDisplayProduct.loadProducts();
    var result = products;
    if (widget.categoryId != null) {
      result = result.where((p) => p.categoryId == widget.categoryId).toList(growable: false);
    }
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return result;
    return result.where((p) {
      final haystack = [p.title, p.categoryTitle, p.groupTitle].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StoreDisplayProduct>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoading(label: 'Loading products...');
        }
        if (snapshot.hasError) {
          return const EmptyState(
            title: 'Unable to load Store products.',
            icon: Icons.cloud_off_outlined,
          );
        }

        final products = snapshot.data ?? const <StoreDisplayProduct>[];
        if (products.isEmpty) {
          return const EmptyState(
            title: 'No products available from Store Management.',
            icon: Icons.local_cafe,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1200 ? 4 : width >= 850 ? 3 : width >= 560 ? 2 : 1;
            final spacing = width >= 850 ? 10.0 : 12.0;
            final aspectRatio = columns >= 4 ? 1.30 : columns == 3 ? 1.22 : columns == 2 ? 1.15 : 2.2;

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return KioskProductCard(
                  product: product,
                  isFavorite: _favoriteService.isFavorite(product.recipeRef),
                  onTap: () async {
                    await AppRouter.push(
                      context,
                      RecipePage(
                        recipePath: product.recipeRef,
                        imagePath: product.image,
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  onFavorite: () => _favoriteService.toggle(product.recipeRef),
                );
              },
            );
          },
        );
      },
    );
  }
}
