import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_settings.dart';
import 'core/auth/auth_gate.dart';

class BiggerBrewApp extends StatelessWidget {
  /// [homeOverride] is used by widget tests to bypass authentication and
  /// exercise the application UI with a seeded local recipe catalog.
  const BiggerBrewApp({super.key, this.homeOverride});

  final Widget? homeOverride;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsService.instance.notifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: settings.title,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: homeOverride ?? const RecipeGuideAuthGate(),
        );
      },
    );
  }
}
