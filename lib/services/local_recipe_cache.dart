import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent, device-local copy of the Store recipe catalog.
///
/// The payload and its successful-sync timestamp are written together as one
/// JSON value, so a failed write cannot update one without the other. The old
/// v1 keys are still readable for existing installations.
class LocalRecipeCache {
  static const _recordKey = 'recipe_guide_store_record_v2';
  static const _legacyPayloadKey = 'recipe_guide_store_payload_v1';
  static const _legacySyncedAtKey = 'recipe_guide_store_synced_at_v1';

  const LocalRecipeCache();

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final recordRaw = prefs.getString(_recordKey);
    if (recordRaw != null && recordRaw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(recordRaw);
        if (decoded is Map<String, dynamic> && decoded['payload'] is Map) {
          return Map<String, dynamic>.from(decoded['payload'] as Map);
        }
      } catch (_) {
        // Fall through to the last legacy record if the new record is invalid.
      }
    }

    final legacyRaw = prefs.getString(_legacyPayloadKey);
    if (legacyRaw == null || legacyRaw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(legacyRaw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Atomically replaces the local catalog and timestamp only after the full
  /// payload has been downloaded and validated by the caller.
  Future<void> write(Map<String, dynamic> payload) async {
    if (payload.isEmpty) {
      throw const FormatException('The downloaded recipe catalog is empty; existing local recipes were preserved.');
    }
    // Encode before touching persistent storage so serialization failures do
    // not affect the existing catalog.
    final now = DateTime.now().toIso8601String();
    final record = jsonEncode(<String, dynamic>{
      'syncedAt': now,
      'payload': payload,
    });
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_recordKey, record);
    if (!saved) {
      throw StateError('Could not save the recipe catalog locally. The previous catalog was preserved.');
    }
  }

  Future<DateTime?> syncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final recordRaw = prefs.getString(_recordKey);
    if (recordRaw != null) {
      try {
        final decoded = jsonDecode(recordRaw);
        if (decoded is Map<String, dynamic> && decoded['syncedAt'] is String) {
          final date = DateTime.tryParse(decoded['syncedAt'] as String);
          if (date != null) return date;
        }
      } catch (_) {
        // Read the legacy timestamp below.
      }
    }
    final raw = prefs.getString(_legacySyncedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// Explicit user-requested deletion only. Sync/sign-out never calls this.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordKey);
    await prefs.remove(_legacyPayloadKey);
    await prefs.remove(_legacySyncedAtKey);
  }
}
