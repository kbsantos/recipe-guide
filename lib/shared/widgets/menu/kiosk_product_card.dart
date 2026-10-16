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

  Widget _categoryIcon(BuildContext context) {
    final image = product.image?.trim() ?? '';
    if (image.startsWith('https://') || image.startsWith('http://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          image,
          width: 68,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackCategoryIcon(context),
        ),
      );
    }

    return Container(
      width: 68,
      height: 76,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: _fallbackCategoryIcon(context),
    );
  }

  Widget _fallbackCategoryIcon(BuildContext context) {
    final icon = product.categoryIcon.trim();
    if (icon.isNotEmpty && icon.runes.length <= 4) {
      return Text(icon, style: const TextStyle(fontSize: 28));
    }
    return Icon(
      StoreDisplayProduct.fallbackIcon(product.categoryTitle),
      size: 30,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: product.available ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _categoryIcon(context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.categoryTitle.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                              if (onFavorite != null)
                                IconButton(
                                  tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                                  onPressed: onFavorite,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 32,
                                    height: 32,
                                  ),
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 21,
                                    color: isFavorite ? scheme.error : scheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Recipe and preparation guide',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.available ? 'View recipe' : 'Unavailable',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: product.available ? scheme.primary : scheme.error,
                      ),
                    ),
                  ),
                  Icon(
                    product.available ? Icons.menu_book_rounded : Icons.block,
                    size: 21,
                    color: product.available ? scheme.primary : scheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
