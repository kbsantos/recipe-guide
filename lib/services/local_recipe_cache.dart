import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalRecipeCache {
  static const _payloadKey = 'recipe_guide_store_payload_v1';
  static const _syncedAtKey = 'recipe_guide_store_synced_at_v1';

  const LocalRecipeCache();

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_payloadKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_payloadKey, jsonEncode(payload));
    await prefs.setString(_syncedAtKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> syncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_syncedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
