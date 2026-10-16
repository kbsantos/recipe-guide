import 'package:my_shop_recipe_guide/app.dart';
import 'package:my_shop_recipe_guide/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_recipe_catalog.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }

    await tester.pump(step);
  }

  throw TestFailure('Timed out waiting for widget: $finder');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await seedRecipeCatalogForTest();
  });

  testWidgets('search page shows results and clears the query', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    // --------------------------------------------------------
    // Launch app
    // --------------------------------------------------------

    await tester.pumpWidget(const RecipeGuideApp(homeOverride: HomePage()));

    await tester.pump();

    // Search is inline on HomePage; it must not navigate to a separate page.
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'creamer');
    await tester.pump();

    final darkChocolate = find.text('Dark Chocolate');
    await pumpUntilFound(tester, darkChocolate);
    expect(darkChocolate, findsOneWidget);

    final clearButton = find.byTooltip('Clear search');
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pump();

    // Clearing restores the complete locally cached catalog on the same page.
    expect(find.text('1 products'), findsOneWidget);
  });
}
