import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecipeGuideAuth {
  const RecipeGuideAuth();

  static const _storage = FlutterSecureStorage();
  static const _emailKey = 'store_sync_email';
  static const _passwordKey = 'store_sync_password';

  Future<void> saveSyncCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<(String?, String?)> readSyncCredentials() async {
    return (await _storage.read(key: _emailKey), await _storage.read(key: _passwordKey));
  }

  Future<void> clearSyncCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }

  Future<bool> hasSyncCredentials() async {
    final (email, password) = await readSyncCredentials();
    return (email?.trim().isNotEmpty ?? false) && (password?.isNotEmpty ?? false);
  }

  Future<void> connectForSync() async {
    final (email, password) = await readSyncCredentials();
    if (email == null || email.trim().isEmpty || password == null || password.isEmpty) {
      throw StateError('Enter and save the Store email and password in Settings before syncing.');
    }
    await client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  SupabaseClient get client => Supabase.instance.client;
  Session? get session => client.auth.currentSession;
  User? get user => client.auth.currentUser;
  bool get isSignedIn => session != null;

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => client.auth.signOut();
}
