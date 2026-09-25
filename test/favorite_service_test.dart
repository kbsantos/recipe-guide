import 'package:bigger_brew_barista/services/favorite_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryFavoriteStorage implements FavoriteStorage {
  List<String>? storedPaths;

  @override
  Future<List<String>?> readFavoriteRecipePaths() async => storedPaths;

  @override
  Future<void> writeFavoriteRecipePaths(List<String> recipePaths) async {
    storedPaths = List<String>.from(recipePaths);
  }
}

void main() {
  test('loads persisted favorites and toggles one favorite', () async {
    final storage = _MemoryFavoriteStorage()..storedPaths = ['dark_chocolate'];
    final service = FavoriteService(storage: storage);

    await service.load();
    expect(service.isFavorite('dark_chocolate'), isTrue);

    await service.toggle('dark_chocolate');
    expect(service.isFavorite('dark_chocolate'), isFalse);
    expect(storage.storedPaths, isEmpty);

    await service.toggle('chocolate');
    expect(service.isFavorite('chocolate'), isTrue);
    expect(storage.storedPaths, ['chocolate']);
  });
}
