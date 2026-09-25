import 'package:bigger_brew_barista/services/search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  late SearchService searchService;

  setUp(() {
    searchService = SearchService();
  });

  test('search service finds Dark Chocolate by drink name', () async {
    final results = await searchService.search('dark chocolate');

    expect(
      results.any((result) => result.item.title == 'Dark Chocolate'),
      isTrue,
    );
  });

  test('search service returns results for creamer', () async {
    final results = await searchService.search('creamer');

    expect(
      results,
      isNotEmpty,
      reason:
          'No recipes currently match "creamer". '
          'Check the recipe JSON ingredient data.',
    );
  });

  test('search service returns empty results for an empty query', () async {
    final results = await searchService.search('');

    expect(results, isEmpty);
  });

  test('search service ignores surrounding whitespace', () async {
    final results = await searchService.search('  dark chocolate  ');

    expect(
      results.any((result) => result.item.title == 'Dark Chocolate'),
      isTrue,
    );
  });
}
