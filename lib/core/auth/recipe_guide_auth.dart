import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeGuideAuth {
  const RecipeGuideAuth();

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
