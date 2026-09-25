# bigger_brew_barista

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Product Catalog → Recipe Guide Adapter

The Recipe Guide now includes a neutral product-to-recipe mapping at
`assets/catalog/recipe_product_mapping.json` and the
`ProductRecipeAdapter` in `lib/adapters/product_recipe_adapter.dart`.

The adapter uses the stable Product Catalog `productId` to resolve a local
Recipe Guide recipe path. It does not import Kiosk code and does not make the
Kiosk depend on `RecipeRepository`.

The two Chocolate products are explicitly disambiguated:

- `chocolate` → `chocolate_milktea`
- `hot_chocolate` → `hot_chocolate`

The adapter regression tests cover all 65 catalog drink mappings and verify
that every mapped recipe loads successfully.
