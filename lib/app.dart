import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';

class BiggerBrewApp extends StatelessWidget {
  const BiggerBrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bigger Brew',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      home: HomePage(),
    );
  }
}
