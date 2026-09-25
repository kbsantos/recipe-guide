import 'package:bigger_brew_barista/features/favorites/favorites_page.dart';
import 'package:bigger_brew_barista/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryFavoriteStorage implements FavoriteStorage {
  _MemoryFavoriteStorage(this.storedPaths);

  List<String>? storedPaths;

  @override
  Future<List<String>?> readFavoriteRecipePaths() async => storedPaths;

  @override
  Future<void> writeFavoriteRecipePaths(List<String> recipePaths) async {
    storedPaths = List<String>.from(recipePaths);
  }
}

void main() {
  testWidgets('shows and removes a persisted favorite drink', (tester) async {
    final service = FavoriteService(
      storage: _MemoryFavoriteStorage(['afforda_milktea/dark_chocolate']),
    );

    await tester.pumpWidget(
      MaterialApp(home: FavoritesPage(favoriteService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dark Chocolate'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));

    await tester.tap(find.byTooltip('Remove favorite'));
    await tester.pumpAndSettle();

    expect(find.text('No favorite drinks yet.'), findsOneWidget);
  });
}
