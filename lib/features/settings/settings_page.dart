import 'package:flutter/material.dart';

import 'package:recipe_guide/core/config/app_settings.dart';
import 'package:recipe_guide/core/navigation/app_router.dart';
import 'package:recipe_guide/shared/widgets/base_page.dart';
import 'package:recipe_guide/core/auth/recipe_guide_auth.dart';
import 'package:recipe_guide/core/auth/local_pin_service.dart';
import 'package:recipe_guide/services/local_recipe_cache.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _storeNameController;
  bool _saving = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _credentialsSaved = false;
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = AppSettingsService.instance.notifier.value;
    _titleController = TextEditingController(text: settings.title);
    _subtitleController = TextEditingController(text: settings.subtitle);
    _storeNameController = TextEditingController(text: settings.storeName);
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final (email, password) = await const RecipeGuideAuth()
        .readSyncCredentials();
    if (!mounted) return;
    setState(() {
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
      _credentialsSaved =
          email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _storeNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    if (title.isEmpty || subtitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and subtitle are required.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await AppSettingsService.instance.save(
        AppSettings(
          title: title,
          subtitle: subtitle,
          storeName: _storeNameController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveCredentials() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store email and password are both required.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await const RecipeGuideAuth().saveSyncCredentials(email, password);
      await const RecipeGuideAuth().signOut();
      if (!mounted) return;
      setState(() => _credentialsSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Store sync credentials saved securely. Sync remains manual.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save credentials: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeLocalPin() async {
    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;
    final currentPinIsValid = await const LocalPinService().verify(currentPin);
    if (!mounted) return;
    if (!currentPinIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current local PIN is incorrect.')),
      );
      return;
    }
    if (!RegExp(r'^\d{4,8}$').hasMatch(newPin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PIN must contain 4 to 8 digits.')),
      );
      return;
    }
    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PIN and confirmation do not match.')),
      );
      return;
    }
    if (newPin == currentPin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose a different PIN.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await const LocalPinService().changePin(newPin);
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local unlock PIN changed successfully.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not change local PIN: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearCredentials() async {
    await const RecipeGuideAuth().clearSyncCredentials();
    await const RecipeGuideAuth().signOut();
    if (!mounted) return;
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _credentialsSaved = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Store credentials cleared.')));
  }

  Future<void> _reset() async {
    await AppSettingsService.instance.reset();
    if (!mounted) return;
    final settings = AppSettingsService.instance.notifier.value;
    setState(() {
      _titleController.text = settings.title;
      _subtitleController.text = settings.subtitle;
      _storeNameController.text = settings.storeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Settings',
      actions: [
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => AppRouter.pop(context),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('General', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'App title',
              hintText: 'Recipe Guide',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: 'Subtitle',
              hintText: 'Barista Recipe Guide',
              prefixIcon: Icon(Icons.short_text),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Store / branch name',
              hintText: 'Optional',
              prefixIcon: Icon(Icons.storefront),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save settings'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _saving ? null : _reset,
            icon: const Icon(Icons.restore),
            label: const Text('Restore defaults'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Local Unlock PIN',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Change the PIN used to unlock Recipe Guide offline. This is separate from your Store account credentials used for syncing.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current PIN',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'New PIN (4–8 digits)',
              prefixIcon: Icon(Icons.password),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Confirm new PIN',
              prefixIcon: Icon(Icons.check_circle_outline),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _changeLocalPin,
            icon: const Icon(Icons.key),
            label: const Text('Change local PIN'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Store Database Connection',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the Store account credentials here before syncing. Credentials are stored using secure storage. Recipe sync is never automatic.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Store email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(
              labelText: 'Store password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 12),
          if (_credentialsSaved)
            const Text(
              'Credentials saved. Sync is available from the Home screen.',
            ),
          FilledButton.icon(
            onPressed: _saving ? null : _saveCredentials,
            icon: const Icon(Icons.lock),
            label: const Text('Save Store credentials securely'),
          ),
          OutlinedButton.icon(
            onPressed: _saving ? null : _clearCredentials,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Store credentials'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          Text('Local Recipes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Recipes are saved on this device and remain available offline. Signing out or a failed sync does not delete them.',
          ),
          const SizedBox(height: 8),
          FutureBuilder<DateTime?>(
            future: const LocalRecipeCache().syncedAt(),
            builder: (context, snapshot) {
              final date = snapshot.data;
              return Text(
                date == null
                    ? 'Last successful sync: Not synced yet'
                    : 'Last successful sync: ${date.toLocal().toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Clear local recipes?'),
                        content: const Text(
                          'This removes the saved recipe catalog from this device. You will need to sync again to browse recipes.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Clear recipes'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    await const LocalRecipeCache().clear();
                    if (!mounted) return;
                    setState(() {});
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Local recipes cleared.')),
                    );
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear local recipes'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Recipe syncing is manual. Use the sync button on the home screen when you want to refresh the catalog. Store Management remains the source of truth for recipes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
