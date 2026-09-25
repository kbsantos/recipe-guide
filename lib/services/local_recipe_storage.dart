import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'recipe_storage.dart';

class LocalRecipeStorage implements RecipeStorage {
  static const String _prefix = 'recipe_override_';

  final SharedPreferences _preferences;

  LocalRecipeStorage(this._preferences);

  String _key(String recipePath) {
    return '$_prefix$recipePath';
  }

  String _recipePathFromKey(String key) {
    return key.substring(_prefix.length);
  }

  @override
  Future<Recipe?> load(String recipePath) async {
    final jsonString = _preferences.getString(_key(recipePath));

    if (jsonString == null || jsonString.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return Recipe.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String recipePath, Recipe recipe) async {
    final jsonString = json.encode(recipe.toJson());

    await _preferences.setString(_key(recipePath), jsonString);
  }

  @override
  Future<void> delete(String recipePath) async {
    await _preferences.remove(_key(recipePath));
  }

  @override
  Future<bool> exists(String recipePath) async {
    return _preferences.containsKey(_key(recipePath));
  }

  @override
  Future<Map<String, Recipe>> getAll() async {
    final result = <String, Recipe>{};

    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(_prefix))
        .toList();

    for (final key in keys) {
      final recipePath = _recipePathFromKey(key);

      final recipe = await load(recipePath);

      if (recipe != null) {
        result[recipePath] = recipe;
      }
    }

    return result;
  }

  @override
  Future<void> clear() async {
    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(_prefix))
        .toList();

    for (final key in keys) {
      await _preferences.remove(key);
    }
  }
}
