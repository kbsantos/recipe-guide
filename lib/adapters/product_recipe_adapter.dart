import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Neutral Product Catalog -> Recipe Guide adapter.
///
/// The Product Catalog owns the stable commercial `productId`. Recipe Guide
/// owns the recipe implementation. This adapter only resolves the catalog
/// product to the Recipe Guide's local recipe path; it does not expose or
/// share Recipe Guide implementation with the Kiosk.
class ProductRecipeReference {
  final String productId;
  final String productName;
  final String recipeId;
  final String recipePath;
  final String recipeRef;

  const ProductRecipeReference({
    required this.productId,
    required this.productName,
    required this.recipeId,
    required this.recipePath,
    required this.recipeRef,
  });

  factory ProductRecipeReference.fromJson(Map<String, dynamic> json) {
    return ProductRecipeReference(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      recipeId: json['recipeId']?.toString() ?? '',
      recipePath: json['recipePath']?.toString() ?? '',
      recipeRef: json['recipeRef']?.toString() ?? '',
    );
  }
}

class ProductRecipeAdapter {
  ProductRecipeAdapter._();

  static const _assetPath = 'assets/catalog/recipe_product_mapping.json';

  static Future<List<ProductRecipeReference>> loadReferences() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final products = json['products'] as List<dynamic>? ?? const [];

    return products
        .map(
          (entry) => ProductRecipeReference.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList(growable: false);
  }

  static Future<ProductRecipeReference?> findReference(
    String productId,
  ) async {
    final references = await loadReferences();

    for (final reference in references) {
      if (reference.productId == productId) {
        return reference;
      }
    }

    return null;
  }

  /// Loads a Recipe Guide recipe using the stable Product Catalog ID.
  static Future<Recipe> loadRecipe(String productId) async {
    final reference = await findReference(productId);

    if (reference == null) {
      throw StateError(
        'No Recipe Guide mapping exists for productId "$productId".',
      );
    }

    return RecipeRepository.loadRecipe(reference.recipePath);
  }
}
