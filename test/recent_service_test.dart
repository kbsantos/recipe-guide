import 'package:bigger_brew_barista/services/recent_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRecentStorage implements RecentStorage {
  List<String>? storedPaths;

  @override
  Future<List<String>?> readRecentRecipePaths() async => storedPaths;

  @override
  Future<void> writeRecentRecipePaths(List<String> recipePaths) async {
    storedPaths = List<String>.from(recipePaths);
  }
}

void main() {
  test(
    'records unique paths, moves reopened drinks to the top, and limits history',
    () async {
      final storage = _MemoryRecentStorage();
      final service = RecentService(storage: storage, maxItems: 3);

      await service.record('first');
      await service.record('second');
      await service.record('first');
      await service.record('third');
      await service.record('fourth');

      expect(service.recentRecipePaths, ['fourth', 'third', 'first']);
      expect(storage.storedPaths, ['fourth', 'third', 'first']);
    },
  );

  test('loads and clears persisted history', () async {
    final storage = _MemoryRecentStorage()..storedPaths = ['dark', 'chocolate'];
    final service = RecentService(storage: storage);

    await service.load();
    expect(service.recentRecipePaths, ['dark', 'chocolate']);

    await service.clear();
    expect(service.recentRecipePaths, isEmpty);
    expect(storage.storedPaths, isEmpty);
  });
}
