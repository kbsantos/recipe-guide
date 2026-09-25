import 'package:bigger_brew_barista/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shows recent drinks through the history action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Recent drinks'), findsOneWidget);
    expect(find.text('Recent Drinks'), findsNothing);
  });
}
