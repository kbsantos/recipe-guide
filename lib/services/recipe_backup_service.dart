import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'local_recipe_storage.dart';
import 'recipe_storage.dart';

class RecipeBackupService {
  RecipeBackupService._();

  static const int backupVersion = 1;

  static RecipeStorage? _storage;

  // ==========================================================
  // STORAGE
  // ==========================================================

  static Future<RecipeStorage> _getStorage() async {
    if (_storage != null) {
      return _storage!;
    }

    final preferences = await SharedPreferences.getInstance();

    _storage = LocalRecipeStorage(preferences);

    return _storage!;
  }

  // ==========================================================
  // CREATE BACKUP
  // ==========================================================

  static Future<Map<String, dynamic>> createBackup() async {
    final storage = await _getStorage();

    final recipes = await storage.getAll();

    final recipeData = <String, dynamic>{};

    for (final entry in recipes.entries) {
      recipeData[entry.key] = entry.value.toJson();
    }

    return {
      'version': backupVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'recipeCount': recipeData.length,
      'recipes': recipeData,
    };
  }

  // ==========================================================
  // CREATE BACKUP JSON
  // ==========================================================

  static Future<String> createBackupJson() async {
    final backup = await createBackup();

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  // ==========================================================
  // EXPORT BACKUP
  // ==========================================================

  static Future<void> exportBackup() async {
    final jsonString = await createBackupJson();

    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    await FileSaver.instance.saveFile(
      name: 'bigger_brew_recipe_backup',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }

  // ==========================================================
  // PICK BACKUP FILE
  // ==========================================================

  static Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );

    // User cancelled the picker.
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('The selected backup file is empty.');
    }

    try {
      return utf8.decode(bytes);
    } catch (_) {
      throw const FormatException(
        'The selected backup file is not valid UTF-8 text.',
      );
    }
  }

  // ==========================================================
  // VALIDATE BACKUP
  // ==========================================================

  static Map<String, dynamic> validateBackup(String jsonString) {
    dynamic decoded;

    // --------------------------------------------------------
    // JSON VALIDATION
    // --------------------------------------------------------

    try {
      decoded = json.decode(jsonString);
    } catch (_) {
      throw const FormatException('The backup file contains invalid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup format.');
    }

    // --------------------------------------------------------
    // VERSION
    // --------------------------------------------------------

    final version = decoded['version'];

    if (version is! int) {
      throw const FormatException('Backup version is missing.');
    }

    if (version != backupVersion) {
      throw FormatException('Unsupported backup version: $version');
    }

    // --------------------------------------------------------
    // RECIPES
    // --------------------------------------------------------

    final recipes = decoded['recipes'];

    if (recipes is! Map<String, dynamic>) {
      throw const FormatException(
        'Backup does not contain a valid recipes section.',
      );
    }

    // --------------------------------------------------------
    // VALIDATE EVERY RECIPE
    //
    // Nothing is written to storage until the
    // entire backup has passed validation.
    // --------------------------------------------------------

    for (final entry in recipes.entries) {
      final recipePath = entry.key;
      final recipeJson = entry.value;

      if (recipePath.trim().isEmpty) {
        throw const FormatException('A recipe path is empty.');
      }

      if (recipeJson is! Map<String, dynamic>) {
        throw FormatException('Invalid recipe data for "$recipePath".');
      }

      try {
        Recipe.fromJson(Map<String, dynamic>.from(recipeJson));
      } catch (error) {
        throw FormatException('Invalid recipe "$recipePath": $error');
      }
    }

    return decoded;
  }

  // ==========================================================
  // RESTORE BACKUP JSON
  // ==========================================================

  static Future<int> restoreBackupJson(String jsonString) async {
    // --------------------------------------------------------
    // IMPORTANT:
    // Validate the entire backup FIRST.
    // --------------------------------------------------------

    final backup = validateBackup(jsonString);

    final recipes = backup['recipes'] as Map<String, dynamic>;

    final storage = await _getStorage();

    // --------------------------------------------------------
    // Only clear existing overrides after the backup
    // has been completely validated.
    // --------------------------------------------------------

    await storage.clear();

    // --------------------------------------------------------
    // RESTORE RECIPES
    // --------------------------------------------------------

    for (final entry in recipes.entries) {
      final recipePath = entry.key;

      final recipeJson = Map<String, dynamic>.from(entry.value as Map);

      final recipe = Recipe.fromJson(recipeJson);

      await storage.save(recipePath, recipe);
    }

    return recipes.length;
  }

  // ==========================================================
  // IMPORT BACKUP
  // ==========================================================

  static Future<int?> importBackup() async {
    final jsonString = await pickBackupFile();

    // User cancelled file picker.
    if (jsonString == null) {
      return null;
    }

    return restoreBackupJson(jsonString);
  }

  // ==========================================================
  // GET MODIFIED RECIPE COUNT
  // ==========================================================

  static Future<int> getModifiedRecipeCount() async {
    final storage = await _getStorage();

    final recipes = await storage.getAll();

    return recipes.length;
  }

  // ==========================================================
  // GET MODIFIED RECIPES
  // ==========================================================

  static Future<Map<String, Recipe>> getModifiedRecipes() async {
    final storage = await _getStorage();

    return storage.getAll();
  }

  // ==========================================================
  // CLEAR LOCAL RECIPE OVERRIDES
  // ==========================================================

  static Future<void> clearLocalRecipes() async {
    final storage = await _getStorage();

    await storage.clear();
  }
}
