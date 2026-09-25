import 'package:flutter_test/flutter_test.dart';
import 'package:bigger_brew_barista/adapters/product_recipe_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Catalog -> Recipe Guide adapter', () {
    test('contains the 65 catalog drink-to-recipe mappings', () async {
      final references = await ProductRecipeAdapter.loadReferences();

      expect(references, hasLength(65));
      expect(
        references.map((reference) => reference.productId).toSet(),
        hasLength(65),
      );
    });

    test('resolves a normal product by stable productId', () async {
      final reference = await ProductRecipeAdapter.findReference(
        'biscoff_milktea',
      );

      expect(reference, isNotNull);
      expect(reference!.recipeId, 'biscoff_milktea');
      expect(reference.recipePath, 'signature_milktea/biscoff_milktea');
    });

    test('keeps the two Chocolate products unambiguous', () async {
      final milkTea = await ProductRecipeAdapter.findReference('chocolate');
      final hotChocolate = await ProductRecipeAdapter.findReference(
        'hot_chocolate',
      );

      expect(milkTea, isNotNull);
      expect(milkTea!.recipeId, 'chocolate_milktea');
      expect(milkTea.recipePath, 'afforda_milktea/chocolate');

      expect(hotChocolate, isNotNull);
      expect(hotChocolate!.recipeId, 'hot_chocolate');
      expect(hotChocolate.recipePath, 'hot_coffee/chocolate');
    });

    test('loads every mapped recipe through RecipeRepository', () async {
      final references = await ProductRecipeAdapter.loadReferences();

      for (final reference in references) {
        final recipe = await ProductRecipeAdapter.loadRecipe(
          reference.productId,
        );

        expect(
          recipe.id,
          reference.recipeId,
          reason: 'Unexpected recipe ID for ${reference.productId}',
        );
      }
    });

    test('returns no reference for an unknown productId', () async {
      expect(
        await ProductRecipeAdapter.findReference('not_a_real_product'),
        isNull,
      );
    });
  });
}
