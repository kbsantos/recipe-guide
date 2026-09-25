import 'menu_item.dart';

class SearchResult {
  final MenuItem item;
  final String category;
  final String group;
  final List<String> ingredientNames;

  const SearchResult({
    required this.item,
    required this.category,
    required this.group,
    required this.ingredientNames,
  });
}
