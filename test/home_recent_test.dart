import 'package:recipe_guide/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_recipe_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await seedRecipeCatalogForTest();
  });

  testWidgets(
    'home keeps the product search and does not show Recent Drinks UI',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byTooltip('Recent drinks'), findsNothing);
      expect(find.text('Recent Drinks'), findsNothing);
    },
  );
}
