import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RecentStorage {
  Future<List<String>?> readRecentRecipePaths();
  Future<void> writeRecentRecipePaths(List<String> recipePaths);
}

class SharedPreferencesRecentStorage implements RecentStorage {
  static const _storageKey = 'recent_recipe_paths';
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<List<String>?> readRecentRecipePaths() {
    return _instance.getStringList(_storageKey);
  }

  @override
  Future<void> writeRecentRecipePaths(List<String> recipePaths) {
    return _instance.setStringList(_storageKey, recipePaths);
  }
}

class RecentService extends ChangeNotifier {
  RecentService({RecentStorage? storage, this.maxItems = 5})
    : _storage = storage ?? SharedPreferencesRecentStorage();

  static final instance = RecentService();

  final RecentStorage _storage;
  final int maxItems;
  final List<String> _recentRecipePaths = <String>[];
  Future<void>? _loadFuture;

  List<String> get recentRecipePaths => List.unmodifiable(_recentRecipePaths);

  Future<void> load() => _loadFuture ??= _loadRecents();

  Future<void> record(String recipePath) async {
    await load();

    _recentRecipePaths
      ..remove(recipePath)
      ..insert(0, recipePath);
    if (_recentRecipePaths.length > maxItems) {
      _recentRecipePaths.removeRange(maxItems, _recentRecipePaths.length);
    }

    await _saveSafely();
    notifyListeners();
  }

  Future<void> clear() async {
    await load();
    if (_recentRecipePaths.isEmpty) {
      return;
    }

    _recentRecipePaths.clear();
    await _saveSafely();
    notifyListeners();
  }

  Future<void> _loadRecents() async {
    List<String>? storedPaths;
    try {
      storedPaths = await _storage.readRecentRecipePaths();
    } catch (_) {
      // Recent drinks remain usable for the current session if storage fails.
    }

    for (final recipePath in storedPaths ?? const <String>[]) {
      if (!_recentRecipePaths.contains(recipePath) &&
          _recentRecipePaths.length < maxItems) {
        _recentRecipePaths.add(recipePath);
      }
    }
    notifyListeners();
  }

  Future<void> _saveSafely() async {
    try {
      await _storage.writeRecentRecipePaths(_recentRecipePaths);
    } catch (_) {
      // Keep the current session responsive if a storage write fails.
    }
  }
}
