import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/json_loader.dart';
import '../models/recipe.dart';
import '../services/local_recipe_storage.dart';
import '../services/recipe_storage.dart';

class RecipeRepository {
  RecipeRepository._();

  static RecipeStorage? _storage;

  static Future<RecipeStorage> _getStorage() async {
    if (_storage != null) {
      return _storage!;
    }

    final preferences = await SharedPreferences.getInstance();

    _storage = LocalRecipeStorage(preferences);

    return _storage!;
  }

  /// Loads a recipe.
  ///
  /// A locally edited recipe takes priority
  /// over the bundled JSON asset.
  static Future<Recipe> loadRecipe(String recipePath) async {
    final storage = await _getStorage();

    final localRecipe = await storage.load(recipePath);

    if (localRecipe != null) {
      return localRecipe;
    }

    final Map<String, dynamic> json = await JsonLoader.load(
      'assets/recipes/$recipePath.json',
    );

    return Recipe.fromJson(json);
  }

  /// Saves a local recipe override.
  static Future<void> saveRecipe(String recipePath, Recipe recipe) async {
    final storage = await _getStorage();

    await storage.save(recipePath, recipe);
  }

  /// Removes the local override.
  ///
  /// The next load will return the original
  /// bundled JSON recipe.
  static Future<void> resetRecipe(String recipePath) async {
    final storage = await _getStorage();

    await storage.delete(recipePath);
  }

  /// Returns true when a recipe has a local
  /// edited version.
  static Future<bool> hasLocalOverride(String recipePath) async {
    final storage = await _getStorage();

    return storage.exists(recipePath);
  }

  /// Removes all local recipe overrides.
  static Future<void> clearLocalRecipes() async {
    final storage = await _getStorage();

    await storage.clear();
  }
}
