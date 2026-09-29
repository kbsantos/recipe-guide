import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/auth/recipe_guide_auth.dart';
import '../core/config/app_settings.dart';
import 'local_recipe_cache.dart';

class StoreRecipeSyncService {
  const StoreRecipeSyncService();

  static const _rpcName = 'get_recipe_guide_catalog';

  Future<Map<String, dynamic>> sync() async {
    final auth = const RecipeGuideAuth();
    if (!auth.isSignedIn) throw StateError('Sign in to sync recipes from Store Management.');

    final response = await auth.client.rpc(_rpcName);
    final payload = Map<String, dynamic>.from(response as Map);
    await const LocalRecipeCache().write(payload);
    return payload;
  }

  Future<Map<String, dynamic>?> loadCache() => const LocalRecipeCache().read();

  Future<Map<String, dynamic>> syncOnStartupOrCache() async {
    if (!AppSettingsService.instance.notifier.value.autoSync) {
      final cached = await loadCache();
      if (cached != null) return cached;
      return sync();
    }
    return syncOrCache();
  }

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
