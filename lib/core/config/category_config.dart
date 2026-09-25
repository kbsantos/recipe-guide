import 'package:flutter/material.dart';

import '../../models/category_type.dart';

class CategoryConfig {
  CategoryConfig._();

  static IconData icon(CategoryType type) {
    switch (type) {
      case CategoryType.coffee:
        return Icons.coffee;

      case CategoryType.milkTea:
        return Icons.local_cafe;

      case CategoryType.matcha:
        return Icons.spa;

      case CategoryType.frappe:
        return Icons.icecream;

      case CategoryType.fruitTea:
        return Icons.local_drink;

      case CategoryType.fruitySoda:
        return Icons.sports_bar;

      case CategoryType.slushies:
        return Icons.ac_unit;
    }
  }

  static Color color(CategoryType type) {
    switch (type) {
      case CategoryType.coffee:
        return Colors.brown;

      case CategoryType.milkTea:
        return Colors.amber;

      case CategoryType.matcha:
        return Colors.green;

      case CategoryType.frappe:
        return Colors.blue;

      case CategoryType.fruitTea:
        return Colors.orange;

      case CategoryType.fruitySoda:
        return Colors.deepPurple;

      case CategoryType.slushies:
        return Colors.cyan;
    }
  }
}
