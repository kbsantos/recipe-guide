import 'menu_item.dart';

class MenuGroup {
  final String id;
  final String title;
  final List<MenuItem> items;

  const MenuGroup({required this.id, required this.title, required this.items});
}
