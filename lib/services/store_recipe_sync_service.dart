import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/auth/recipe_guide_auth.dart';
import 'local_recipe_cache.dart';

class StoreRecipeSyncService {
  const StoreRecipeSyncService();

  static const _rpcName = 'get_recipe_guide_catalog';

  Future<Map<String, dynamic>> sync() async {
    final auth = const RecipeGuideAuth();
    if (!await auth.hasSyncCredentials()) {
      throw StateError('Set and save the Store email and password in Settings before syncing.');
    }

    try {
      // Open an authenticated session only for this user-triggered sync.
      await auth.connectForSync();
      final response = await auth.client.rpc(_rpcName);
      final payload = Map<String, dynamic>.from(response as Map);
      // Persist locally before closing the session, so normal app use is offline-first.
      await const LocalRecipeCache().write(payload);
      return payload;
    } finally {
      // Always close the authenticated session, including when auth, RPC, or cache
      // writing fails. Never let cleanup replace the original sync error.
      try {
        await auth.signOut();
      } catch (_) {
        // Supabase may already have cleared the session; cached recipes are retained.
      }
    }
  }

  Future<Map<String, dynamic>?> loadCache() => const LocalRecipeCache().read();

  Future<Map<String, dynamic>> syncOrCache() async {
    try {
      return await sync();
    } on PostgrestException {
      final cached = await loadCache();
      if (cached != null) return cached;
      rethrow;
    } catch (_) {
      final cached = await loadCache();
      if (cached != null) return cached;
      rethrow;
    }
  }
}
