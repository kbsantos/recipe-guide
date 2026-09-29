import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _recipePayload = {
  'schemaVersion': 1,
  'catalogVersion': 'test',
  'recipes': [
    {
      'id': 'afforda_milktea/dark_chocolate',
      'productId': 'dark_chocolate',
      'title': 'Dark Chocolate',
      'categoryId': 'milk_tea',
      'group': 'Afforda Milktea',
      'image': null,
      'sizes': [
        {
          'sizeId': 'regular',
          'size': 'Regular',
          'ingredients': [
            {
              'id': 'dark_chocolate_powder',
              'name': 'Dark Chocolate Powder',
              'amount': '2',
              'quantity': 2,
              'unit': 'scoop',
            },
            {
              'id': 'creamer',
              'name': 'Creamer',
              'amount': '30',
              'quantity': 30,
              'unit': 'g',
            },
            {
              'id': 'fructose',
              'name': 'Fructose',
              'amount': '20',
              'quantity': 20,
              'unit': 'ml',
            },
          ],
          'steps': [
            'Add Dark Chocolate Powder.',
            'Add Creamer.',
            'Add Fructose.',
          ],
        },
      ],
    },
  ],
};

Future<void> seedRecipeCatalogForTest() async {
  SharedPreferences.setMockInitialValues({
    'recipe_guide_store_payload_v1': jsonEncode(_recipePayload),
  });
}
