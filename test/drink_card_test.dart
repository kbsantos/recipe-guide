import 'package:bigger_brew_barista/shared/widgets/menu/drink_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('falls back to a placeholder when an image asset is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrinkCard(
            title: 'Dark Chocolate',
            imagePath: 'assets/images/drinks/not_available.png',
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.local_cafe), findsOneWidget);
  });
}
