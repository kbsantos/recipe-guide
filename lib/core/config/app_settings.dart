import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String title;
  final String subtitle;
  final String storeName;

  const AppSettings({
    required this.title,
    required this.subtitle,
    required this.storeName,
  });

  static const defaults = AppSettings(
    title: 'Recipe Guide',
    subtitle: 'Barista Recipe Guide',
    storeName: '',
  );

  AppSettings copyWith({String? title, String? subtitle, String? storeName}) {
    return AppSettings(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      storeName: storeName ?? this.storeName,
    );
  }
}

class AppSettingsService {
  AppSettingsService._();
  static final instance = AppSettingsService._();

  static const _titleKey = 'settings.app_title';
  static const _subtitleKey = 'settings.app_subtitle';
  static const _storeNameKey = 'settings.store_name';

  final ValueNotifier<AppSettings> notifier = ValueNotifier<AppSettings>(
    AppSettings.defaults,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('settings.auto_sync');
    notifier.value = AppSettings(
      title: prefs.getString(_titleKey) ?? AppSettings.defaults.title,
      subtitle: prefs.getString(_subtitleKey) ?? AppSettings.defaults.subtitle,
      storeName:
          prefs.getString(_storeNameKey) ?? AppSettings.defaults.storeName,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_titleKey, settings.title);
    await prefs.setString(_subtitleKey, settings.subtitle);
    await prefs.setString(_storeNameKey, settings.storeName);
    // Remove the legacy preference. Recipe syncing is now manual only.
    await prefs.remove('settings.auto_sync');
    notifier.value = settings;
  }

  Future<void> reset() => save(AppSettings.defaults);

  void dispose() => notifier.dispose();
}
