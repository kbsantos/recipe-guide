import 'recipe_size.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String group;

  final List<RecipeSize> sizes;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.group,
    required this.sizes,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final sizesJson = json['sizes'] as Map<String, dynamic>;

    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      group: json['group'] ?? '',

      sizes: sizesJson.entries
          .map((entry) => RecipeSize.fromJson(entry.key, entry.value))
          .toList(),

      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  RecipeSize? getSize(String size) {
    try {
      return sizes.firstWhere((recipeSize) => recipeSize.size == size);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'group': group,

      'sizes': {
        for (final size in sizes)
          size.size: {
            'ingredients': size.ingredients
                .map((ingredient) => ingredient.toJson())
                .toList(),
          },
      },

      'steps': steps,
    };
  }
}
