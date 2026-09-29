import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/home_page.dart';
import '../../services/store_recipe_sync_service.dart';
import 'login_page.dart';

class RecipeGuideAuthGate extends StatelessWidget {
  const RecipeGuideAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (Supabase.instance.client.auth.currentSession == null) {
          return const RecipeGuideLoginPage();
        }
        return const _RecipeSyncGate();
      },
    );
  }
}

class _RecipeSyncGate extends StatefulWidget {
  const _RecipeSyncGate();

  @override
  State<_RecipeSyncGate> createState() => _RecipeSyncGateState();
}

class _RecipeSyncGateState extends State<_RecipeSyncGate> {
  late Future<Map<String, dynamic>> _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = const StoreRecipeSyncService().syncOnStartupOrCache();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _syncFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Syncing recipes from Store Management...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 52),
                    const SizedBox(height: 12),
                    const Text(
                      'Recipe data is not available.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _syncFuture = const StoreRecipeSyncService().syncOnStartupOrCache();
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('TRY AGAIN'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const HomePage();
      },
    );
  }
}
