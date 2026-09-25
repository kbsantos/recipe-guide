import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoriteStorage {
  Future<List<String>?> readFavoriteRecipePaths();
  Future<void> writeFavoriteRecipePaths(List<String> recipePaths);
}

class SharedPreferencesFavoriteStorage implements FavoriteStorage {
  static const _storageKey = 'favorite_recipe_paths';
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<List<String>?> readFavoriteRecipePaths() {
    return _instance.getStringList(_storageKey);
  }

  @override
  Future<void> writeFavoriteRecipePaths(List<String> recipePaths) {
    return _instance.setStringList(_storageKey, recipePaths);
  }
}

class FavoriteService extends ChangeNotifier {
  FavoriteService({FavoriteStorage? storage})
    : _storage = storage ?? SharedPreferencesFavoriteStorage();

  static final instance = FavoriteService();

  final FavoriteStorage _storage;
  final Set<String> _favoriteRecipePaths = <String>{};
  Future<void>? _loadFuture;

  Set<String> get favoriteRecipePaths => Set.unmodifiable(_favoriteRecipePaths);

  bool isFavorite(String recipePath) =>
      _favoriteRecipePaths.contains(recipePath);

  Future<void> load() {
    return _loadFuture ??= _loadFavorites();
  }

  Future<void> toggle(String recipePath) async {
    await load();

    if (!_favoriteRecipePaths.add(recipePath)) {
      _favoriteRecipePaths.remove(recipePath);
    }

    try {
      await _save();
    } catch (_) {
      // Keep the current session responsive if a storage write fails.
    }
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    List<String>? storedPaths;
    try {
      storedPaths = await _storage.readFavoriteRecipePaths();
    } catch (_) {
      // Favorites remain usable for the current session if storage is offline.
    }
    _favoriteRecipePaths
      ..clear()
      ..addAll(storedPaths ?? const <String>[]);
    notifyListeners();
  }

  Future<void> _save() {
    final paths = _favoriteRecipePaths.toList()..sort();
    return _storage.writeFavoriteRecipePaths(paths);
  }
}
