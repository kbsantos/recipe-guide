import 'package:bigger_brew_barista/models/menu_item.dart';
import 'package:bigger_brew_barista/models/search_result.dart';
import 'package:bigger_brew_barista/services/local_recipe_cache.dart';
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

  bool _matches(SearchResult result, String query) {
    if (result.item.title.toLowerCase().contains(query)) {
      return true;
    }

    if (result.category.toLowerCase().contains(query)) {
      return true;
    }

    if (result.group.toLowerCase().contains(query)) {
      return true;
    }

    return result.ingredientNames.any(
      (ingredient) => ingredient.toLowerCase().contains(query),
    );
  }

  /// Builds the search index from the Store Management recipe payload.
  ///
  /// Recipe Guide must not maintain a second catalog/recipe source, so
  /// search deliberately reads the same locally cached Store payload used
  /// by RecipeRepository.
  Future<List<SearchResult>> _buildSearchIndex() async {
    final results = <SearchResult>[];
    final payload = await const LocalRecipeCache().read();
    final recipes = payload?['recipes'];

    if (recipes is! List) {
      debugPrint('SEARCH INDEX: no synced Store recipe catalog available.');
      return const [];
    }

    final seenIds = <String>{};

    for (final raw in recipes) {
      if (raw is! Map) continue;

      final recipe = Map<String, dynamic>.from(raw);
      final recipeId = recipe['id']?.toString().trim() ?? '';
      final title = recipe['title']?.toString().trim() ?? '';

      if (recipeId.isEmpty || title.isEmpty || !seenIds.add(recipeId)) {
        continue;
      }

      final ingredientNames = <String>{};
      final rawSizes = recipe['sizes'];

      if (rawSizes is List) {
        for (final rawSize in rawSizes) {
          if (rawSize is! Map) continue;

          final ingredients = rawSize['ingredients'];
          if (ingredients is! List) continue;

          for (final rawIngredient in ingredients) {
            if (rawIngredient is! Map) continue;

            final name = rawIngredient['name']?.toString().trim() ?? '';
            if (name.isNotEmpty) {
              ingredientNames.add(name);
            }
          }
        }
      }

      final category = recipe['categoryId']?.toString() ?? '';
      final group = recipe['group']?.toString() ?? '';

      results.add(
        SearchResult(
          item: MenuItem(
            id: recipe['productId']?.toString() ?? recipeId,
            title: title,
            recipePath: recipeId,
            imagePath: recipe['image']?.toString(),
          ),
          category: category,
          group: group,
          ingredientNames: ingredientNames.toList(growable: false),
        ),
      );
    }

    debugPrint('========================================');
    debugPrint('SEARCH INDEX DEBUG');
    debugPrint('STORE RECIPES: ${recipes.length}');
    debugPrint('INDEXED RECIPES: ${results.length}');
    debugPrint('========================================');

    return List.unmodifiable(results);
  }
}
