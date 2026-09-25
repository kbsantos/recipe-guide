import 'package:bigger_brew_barista/models/search_result.dart';
import 'package:bigger_brew_barista/repositories/menu_repository.dart';
import 'package:bigger_brew_barista/repositories/recipe_repository.dart';
import 'package:flutter/foundation.dart';

class SearchService {
  Future<List<SearchResult>>? _searchIndexFuture;

  Future<List<SearchResult>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final searchIndex = await (_searchIndexFuture ??= _buildSearchIndex());

    return searchIndex
        .where((result) => _matches(result, normalizedQuery))
        .toList(growable: false);
  }

  // ==========================================================
  // MATCHING
  // ==========================================================

  bool _matches(SearchResult result, String query) {
    // Drink name
    if (result.item.title.toLowerCase().contains(query)) {
      return true;
    }

    // Category
    if (result.category.toLowerCase().contains(query)) {
      return true;
    }

    // Group
    if (result.group.toLowerCase().contains(query)) {
      return true;
    }

    // Ingredients
    return result.ingredientNames.any(
      (ingredient) => ingredient.toLowerCase().contains(query),
    );
  }

  // ==========================================================
  // BUILD SEARCH INDEX
  // ==========================================================

  Future<List<SearchResult>> _buildSearchIndex() async {
    final results = <SearchResult>[];

    final paths = <String>{};

    for (final category in MenuRepository.categories) {
      for (final group in category.groups) {
        for (final item in group.items) {
          // Prevent duplicate recipe entries
          // when the same recipe appears in
          // multiple menu locations.
          if (!paths.add(item.recipePath)) {
            continue;
          }

          try {
            final recipe = await RecipeRepository.loadRecipe(item.recipePath);

            final ingredientNames = recipe.sizes
                .expand((size) => size.ingredients)
                .map((ingredient) => ingredient.name)
                .where((name) => name.isNotEmpty)
                .toSet()
                .toList(growable: false);

            results.add(
              SearchResult(
                item: item,
                category: category.title,
                group: group.title,
                ingredientNames: ingredientNames,
              ),
            );
          } catch (error, stackTrace) {
            // A missing or invalid recipe should
            // not prevent the remaining menu items
            // from being searchable.
            //
            // Keep the failure visible during
            // development/testing so we can identify
            // broken recipe assets.

            debugPrint(
              'SEARCH INDEX ERROR: '
              '${item.title} → '
              '${item.recipePath}',
            );

            debugPrint('ERROR: $error');

            debugPrint('$stackTrace');
          }
        }
      }
    }

    debugPrint('========================================');

    debugPrint('SEARCH INDEX DEBUG');

    debugPrint(
      'MENU CATEGORIES: '
      '${MenuRepository.categories.length}',
    );

    debugPrint(
      'INDEXED RECIPES: '
      '${results.length}',
    );

    for (final result in results) {
      debugPrint(
        'INDEXED: '
        '${result.item.title} | '
        '${result.category} | '
        '${result.group} | '
        'ingredients: '
        '${result.ingredientNames.join(', ')}',
      );
    }

    debugPrint('========================================');

    return List.unmodifiable(results);
  }
}
