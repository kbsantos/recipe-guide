import 'ingredient.dart';

class RecipeSize {
  final String size;
  final List<Ingredient> ingredients;
  final List<String> steps;

  const RecipeSize({required this.size, required this.ingredients, this.steps = const []});

  factory RecipeSize.fromJson(String size, Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final stepsJson = json['steps'] as List<dynamic>? ?? [];

    return RecipeSize(
      size: size,
      ingredients: ingredientsJson
          .map(
            (ingredientJson) => Ingredient.fromJson(
              Map<String, dynamic>.from(ingredientJson as Map),
            ),
          )
          .toList(),
      steps: stepsJson.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
    };
  }
}
