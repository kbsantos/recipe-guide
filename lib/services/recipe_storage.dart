import '../models/recipe.dart';

abstract class RecipeStorage {
  Future<Recipe?> load(String recipePath);

  Future<void> save(String recipePath, Recipe recipe);

  Future<void> delete(String recipePath);

  Future<bool> exists(String recipePath);

  /// Returns all locally edited recipes.
  ///
  /// The map key is the recipe path, for example:
  ///
  /// hot_coffee/hot_black_coffee
  Future<Map<String, Recipe>> getAll();

  Future<void> clear();
}
