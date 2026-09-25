import 'package:bigger_brew_barista/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('search page shows results and clears the query', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    // --------------------------------------------------------
    // Launch app
    // --------------------------------------------------------

    await tester.pumpWidget(const BiggerBrewApp());

    await tester.pump();

    // --------------------------------------------------------
    // Open Search
    // --------------------------------------------------------

    final searchButton = find.byTooltip('Search drinks');

    expect(searchButton, findsOneWidget);

    await tester.tap(searchButton);

    // Wait specifically for SearchPage.
    final searchField = find.byType(TextField);

    await pumpUntilFound(tester, searchField);

    expect(searchField, findsOneWidget);

    // --------------------------------------------------------
    // Enter search query
    // --------------------------------------------------------

    await tester.enterText(searchField, 'creamer');

    await tester.pump();

    // --------------------------------------------------------
    // Wait for search result
    // --------------------------------------------------------

    final darkChocolate = find.text('Dark Chocolate');

    await pumpUntilFound(tester, darkChocolate);

    // --------------------------------------------------------
    // Verify result
    // --------------------------------------------------------

    expect(darkChocolate, findsOneWidget);

    // --------------------------------------------------------
    // Clear search
    // --------------------------------------------------------

    final clearButton = find.byTooltip('Clear search');

    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);

    await tester.pump();

    // --------------------------------------------------------
    // Verify cleared state
    // --------------------------------------------------------

    expect(
      find.text('Start typing to find a drink or recipe ingredient.'),
      findsOneWidget,
    );
  });
}
