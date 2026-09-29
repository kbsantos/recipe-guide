import 'package:flutter/material.dart';

import 'package:bigger_brew_barista/core/config/app_settings.dart';
import 'package:bigger_brew_barista/core/navigation/app_router.dart';
import 'package:bigger_brew_barista/shared/widgets/base_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _storeNameController;
  bool _autoSync = AppSettings.defaults.autoSync;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = AppSettingsService.instance.notifier.value;
    _titleController = TextEditingController(text: settings.title);
    _subtitleController = TextEditingController(text: settings.subtitle);
    _storeNameController = TextEditingController(text: settings.storeName);
    _autoSync = settings.autoSync;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _storeNameController.dispose();
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
    await AppSettingsService.instance.save(AppSettings(
      title: title,
      subtitle: subtitle,
      storeName: _storeNameController.text.trim(),
      autoSync: _autoSync,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved.')),
    );
  }

  Future<void> _reset() async {
    await AppSettingsService.instance.reset();
    if (!mounted) return;
    final settings = AppSettingsService.instance.notifier.value;
    setState(() {
      _titleController.text = settings.title;
      _subtitleController.text = settings.subtitle;
      _storeNameController.text = settings.storeName;
      _autoSync = settings.autoSync;
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
              hintText: 'Bigger Brew',
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
          Text('Sync', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sync recipes on startup'),
            subtitle: const Text('Keep the local recipe cache updated when the app starts.'),
            value: _autoSync,
            onChanged: (value) => setState(() => _autoSync = value),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
            'Recipe data is managed by Store Management. These settings only control how the Recipe Guide is presented on this device.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
