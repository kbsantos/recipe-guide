
import '../models/recipe.dart';
import '../services/local_recipe_cache.dart';

class RecipeRepository {
  RecipeRepository._();

  static Future<Recipe> loadRecipe(String recipeRef) async {
    final cached = await const LocalRecipeCache().read();
    final remote = _findRemoteRecipe(cached, recipeRef);
    if (remote != null) {
      return Recipe.fromJson(_remoteToRecipeJson(remote));
    }

    throw StateError(
      'Recipe "$recipeRef" is not available from Store Management. Sync the Recipe Guide first.',
    );
  }

  static Map<String, dynamic>? _findRemoteRecipe(
    Map<String, dynamic>? payload,
    String recipeRef,
  ) {
    final recipes = payload?['recipes'];
    if (recipes is! List) return null;
    for (final raw in recipes) {
      if (raw is Map && raw['id']?.toString() == recipeRef) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  static Map<String, dynamic> _remoteToRecipeJson(Map<String, dynamic> remote) {
    final sizes = <String, dynamic>{};
    final rawSizes = remote['sizes'];
    if (rawSizes is List) {
      for (final raw in rawSizes) {
        if (raw is! Map) continue;
        final size = raw['size']?.toString() ?? raw['sizeId']?.toString() ?? '';
        if (size.isEmpty) continue;
        final ingredients = raw['ingredients'] is List
            ? (raw['ingredients'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : <Map<String, dynamic>>[];
        sizes[size] = {
          'ingredients': ingredients.map((item) => {
            'id': item['id']?.toString() ?? '',
            'name': item['name']?.toString() ?? '',
            'amount': item['amount']?.toString() ?? '',
            'unit': item['unit']?.toString() ?? '',
          }).toList(),
          'steps': raw['steps'] is List
              ? (raw['steps'] as List).map((e) => e.toString()).toList()
              : <String>[],
        };
      }
    }

    final firstSteps = sizes.values
        .whereType<Map>()
        .map((e) => e['steps'])
        .whereType<List>()
        .firstWhere((e) => e.isNotEmpty, orElse: () => const []);

    return {
      'id': remote['id']?.toString() ?? '',
      'title': remote['title']?.toString() ?? '',
      'category': remote['categoryId']?.toString() ?? '',
      'group': remote['group']?.toString() ?? '',
      'sizes': sizes,
      'steps': firstSteps,
    };
  }
}
