import 'package:flutter/material.dart';

import 'local_recipe_cache.dart';

class StoreDisplayProduct {
  final String id;
  final String title;
  final String categoryId;
  final String categoryTitle;
  final String categoryIcon;
  final String groupTitle;
  final num? price;
  final bool available;
  final String? image;
  final String recipeRef;
  final int sortOrder;

  const StoreDisplayProduct({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.groupTitle,
    required this.price,
    required this.available,
    required this.image,
    required this.recipeRef,
    required this.sortOrder,
  });

  static Future<List<StoreDisplayProduct>> loadProducts() async {
    final payload = await const LocalRecipeCache().read();
    return fromPayload(payload);
  }

  static List<StoreDisplayProduct> fromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return const [];

    final categories = <String, Map<String, dynamic>>{};
    final rawCategories = payload['categories'];
    if (rawCategories is List) {
      for (final raw in rawCategories) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final id = map['id']?.toString() ?? map['categoryId']?.toString() ?? '';
        if (id.isNotEmpty) categories[id] = map;
      }
    }

    final rawRecipes = payload['recipes'];
    if (rawRecipes is! List) return const [];

    final result = <StoreDisplayProduct>[];
    for (var index = 0; index < rawRecipes.length; index++) {
      final raw = rawRecipes[index];
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final id = map['productId']?.toString() ?? map['id']?.toString() ?? '';
      final recipeRef = map['id']?.toString() ?? '';
      final title = map['title']?.toString() ?? map['name']?.toString() ?? '';
      if (id.isEmpty || recipeRef.isEmpty || title.isEmpty) continue;

      final categoryId = map['categoryId']?.toString() ?? '';
      final category = categories[categoryId];
      final price = _fromPrice(map);
      final available = map['available'] != false;
      final sortOrder = _int(map['sortOrder']) ?? index;

      result.add(StoreDisplayProduct(
        id: id,
        title: title,
        categoryId: categoryId,
        categoryTitle: category?['title']?.toString() ?? category?['name']?.toString() ?? categoryId,
        categoryIcon: category?['icon']?.toString() ?? '',
        groupTitle: map['group']?.toString() ?? map['groupName']?.toString() ?? '',
        price: price,
        available: available,
        image: map['image']?.toString(),
        recipeRef: recipeRef,
        sortOrder: sortOrder,
      ));
    }

    result.sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);
      if (order != 0) return order;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return result;
  }

  static num? _fromPrice(Map<String, dynamic> product) {
    final prices = <num>[];
    final base = _number(product['price']);
    if (base != null && base > 0) prices.add(base);

    final sizes = product['sizes'];
    if (sizes is List) {
      for (final raw in sizes) {
        if (raw is! Map) continue;
        final price = _number(raw['price']);
        if (price != null && price > 0) prices.add(price);
      }
    }

    final variants = product['variants'];
    if (variants is List) {
      for (final raw in variants) {
        if (raw is! Map || raw['active'] == false) continue;
        final price = _number(raw['price']);
        if (price != null && price > 0) prices.add(price);
      }
    }

    if (prices.isEmpty) return null;
    prices.sort();
    return prices.first;
  }

  static num? _number(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static IconData fallbackIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('fruit')) return Icons.local_florist;
    if (value.contains('coffee')) return Icons.coffee;
    if (value.contains('matcha')) return Icons.spa;
    if (value.contains('frappe')) return Icons.icecream;
    if (value.contains('snack') || value.contains('food')) return Icons.fastfood;
    return Icons.local_cafe;
  }
}
