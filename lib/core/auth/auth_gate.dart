import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/local_recipe_cache.dart';
import 'local_pin_service.dart';

import '../../features/home/home_page.dart';

/// Local default PIN provides offline access. The server-side PIN flow remains
/// available for establishing a Store session when syncing is needed.
/// Note: a PIN embedded in the app is not a strong security boundary.
class RecipeGuideAuthGate extends StatefulWidget {
  const RecipeGuideAuthGate({super.key});

  @override
  State<RecipeGuideAuthGate> createState() => _RecipeGuideAuthGateState();
}

class _RecipeGuideAuthGateState extends State<RecipeGuideAuthGate> {
  static const _offlineUnlockedKey = 'recipe_guide_offline_unlocked_v1';
  bool _authenticated = false;
  bool _checkingLocalAccess = true;

  @override
  void initState() {
    super.initState();
    _restoreOfflineAccess();
  }

  Future<void> _restoreOfflineAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final previouslyUnlocked = prefs.getBool(_offlineUnlockedKey) ?? false;
      final cachedCatalog = await const LocalRecipeCache().read();
      if (mounted && previouslyUnlocked && cachedCatalog != null) {
        setState(() => _authenticated = true);
      }
    } catch (_) {
      // If local storage is unavailable, fall back to online PIN verification.
    } finally {
      if (mounted) setState(() => _checkingLocalAccess = false);
    }
  }

  Future<void> _logout() async {
    // Logout locks the guide but deliberately preserves saved credentials and
    // the persistent local recipe catalog for the next offline unlock.
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // A local logout must still work when offline or Supabase is unavailable.
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineUnlockedKey, false);
    } catch (_) {
      // Continue locking the current app session even if preference write fails.
    }
    if (mounted) setState(() => _authenticated = false);
  }

  Future<void> _verifyPin(String pin) async {
    // Allow the configured local PIN to unlock cached recipes without network.
    if (await const LocalPinService().verify(pin)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineUnlockedKey, true);
      if (mounted) setState(() => _authenticated = true);
      return;
    }

    // Any other PIN is verified by Supabase to establish a Store session for sync.
    final client = Supabase.instance.client;
    final response = await client.functions.invoke(
      'recipe-guide-pin-login',
      body: {'pin': pin},
    );
    if (response.status < 200 || response.status >= 300) {
      throw StateError('PIN verification failed. Please try again.');
    }
    final body = Map<String, dynamic>.from(response.data as Map);
    final refreshToken = body['refresh_token'] as String?;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('The server did not return a valid session.');
    }
    await client.auth.setSession(refreshToken);
    if (client.auth.currentSession == null) {
      throw StateError(
        'PIN accepted, but a Store session could not be established.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineUnlockedKey, true);
    if (mounted) setState(() => _authenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLocalAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_authenticated) {
      return HomePage(onLogout: _logout);
    }
    return RecipeGuidePinPage(onSubmit: _verifyPin);
  }
}

class RecipeGuidePinPage extends StatefulWidget {
  const RecipeGuidePinPage({super.key, required this.onSubmit});

  final Future<void> Function(String pin) onSubmit;

  @override
  State<RecipeGuidePinPage> createState() => _RecipeGuidePinPageState();
}

class _RecipeGuidePinPageState extends State<RecipeGuidePinPage> {
  String _enteredPin = '';
  String? _error;
  bool _loading = false;

  void _appendDigit(String digit) {
    if (_loading || _enteredPin.length >= 8) return;
    setState(() {
      _enteredPin += digit;
      _error = null;
    });
  }

  void _backspace() {
    if (_loading || _enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_enteredPin.length < 4 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_enteredPin);
    } catch (_) {
      if (mounted) {
        setState(() {
          _enteredPin = '';
          _error =
              'PIN verification failed. Check your connection and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RECIPE GUIDE',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Barista Recipe Guide'),
                  const SizedBox(height: 28),
                  const Text('Enter Admin PIN'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      final filled = index < _enteredPin.length;
                      return Container(
                        width: 11,
                        height: 11,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                      );
                    }),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: row
                            .map(
                              (digit) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: _PinKey(
                                    label: digit,
                                    onTap: () => _appendDigit(digit),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PinKey(
                            label: 'Clear',
                            onTap: () => setState(() {
                              _enteredPin = '';
                              _error = null;
                            }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PinKey(
                            label: '0',
                            onTap: () => _appendDigit('0'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PinKey(
                            label: '⌫',
                            onTap: _backspace,
                            icon: Icons.backspace_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('UNLOCK'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your local unlock PIN opens the guide offline when recipes are saved. Change it in Settings. Store credentials are configured separately for manual sync.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: OutlinedButton(
      onPressed: onTap,
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )
          : Icon(icon),
    ),
  );
}
