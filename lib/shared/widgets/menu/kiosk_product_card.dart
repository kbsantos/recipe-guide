import 'package:flutter/material.dart';

import '../../../services/store_display_catalog.dart';

class KioskProductCard extends StatelessWidget {
  final StoreDisplayProduct product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const KioskProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    this.onFavorite,
  });

  String _priceText() {
    final price = product.price;
    if (price == null) return 'RECIPE';
    final value = price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
    return 'FROM ₱$value';
  }

  Widget _categoryIcon(BuildContext context) {
    if (product.categoryIcon.trim().isNotEmpty) {
      final icon = product.categoryIcon.trim();
      // Store catalog icons are allowed to be emoji/text symbols.
      if (icon.runes.length <= 4) {
        return Text(icon, style: const TextStyle(fontSize: 20));
      }
    }
    return Icon(
      StoreDisplayProduct.fallbackIcon(product.categoryTitle),
      size: 20,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: product.available ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _categoryIcon(context),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      product.categoryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onFavorite != null)
                    IconButton(
                      tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? scheme.error : scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _priceText(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  if (!product.available)
                    Text(
                      'Unavailable',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Icon(Icons.menu_book_outlined, size: 20, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
