import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/store_config.dart';
import 'core/config/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AppSettingsService.instance.load();

  if (!StoreConfig.isConfigured) {
    runApp(const _ConfigurationErrorApp());
    return;
  }

  await Supabase.initialize(
    url: StoreConfig.url,
    publishableKey: StoreConfig.publishableKey,
  );

  runApp(const BiggerBrewApp());
}

class _ConfigurationErrorApp extends StatelessWidget {
  const _ConfigurationErrorApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Supabase is not configured. Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to .env.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      );
}
