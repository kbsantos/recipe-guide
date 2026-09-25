import 'category_type.dart';
import 'menu_group.dart';

class MenuCategory {
  final CategoryType type;
  final String title;
  final String subtitle;
  final List<MenuGroup> groups;

  const MenuCategory({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.groups,
  });

  /// Total number of drinks in this category.
  int get drinkCount {
    return groups.fold(0, (total, group) => total + group.items.length);
  }
}
