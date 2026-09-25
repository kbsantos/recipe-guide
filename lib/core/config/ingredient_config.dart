import 'package:flutter/material.dart';

class IngredientConfig {
  IngredientConfig._();

  static IconData icon(String value) {
    final key = value.trim().toLowerCase();

    if (key.contains('matcha')) {
      return Icons.spa;
    }

    if (key.contains('coffee')) {
      return Icons.coffee;
    }

    if (key.contains('tea')) {
      return Icons.emoji_food_beverage;
    }

    if (key.contains('creamer') || key.contains('milk')) {
      return Icons.local_drink;
    }

    if (key.contains('fructose') ||
        key.contains('syrup') ||
        key.contains('water')) {
      return Icons.water_drop;
    }

    if (key.contains('ice')) {
      return Icons.ac_unit;
    }

    if (key.contains('pearl') || key.contains('boba')) {
      return Icons.circle;
    }

    if (key.contains('powder')) {
      return Icons.cookie;
    }

    return Icons.inventory_2_outlined;
  }

  static Color color(String value) {
    final key = value.trim().toLowerCase();

    if (key.contains('matcha')) {
      return Colors.green;
    }

    if (key.contains('coffee') || key.contains('tea')) {
      return Colors.brown;
    }

    if (key.contains('creamer') || key.contains('milk')) {
      return Colors.blue;
    }

    if (key.contains('fructose') ||
        key.contains('syrup') ||
        key.contains('water')) {
      return Colors.orange;
    }

    if (key.contains('ice')) {
      return Colors.cyan;
    }

    if (key.contains('pearl') || key.contains('boba')) {
      return Colors.deepPurple;
    }

    if (key.contains('powder')) {
      return Colors.deepOrange;
    }

    return Colors.grey;
  }
}
