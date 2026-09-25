import 'package:flutter/material.dart';

import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_size.dart';
import '../../repositories/recipe_repository.dart';

class RecipeEditorPage extends StatefulWidget {
  final Recipe recipe;
  final String recipePath;

  const RecipeEditorPage({
    super.key,
    required this.recipe,
    required this.recipePath,
  });

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _groupController;

  late List<_EditableSize> _sizes;
  late List<TextEditingController> _stepControllers;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.recipe.title);

    _categoryController = TextEditingController(text: widget.recipe.category);

    _groupController = TextEditingController(text: widget.recipe.group);

    _sizes = widget.recipe.sizes
        .map((size) => _EditableSize.fromRecipeSize(size))
        .toList();

    _stepControllers = widget.recipe.steps
        .map((step) => TextEditingController(text: step))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _groupController.dispose();

    for (final size in _sizes) {
      size.dispose();
    }

    for (final controller in _stepControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // SIZE MANAGEMENT
  // ==========================================================

  void _addSize() {
    setState(() {
      _sizes.add(
        _EditableSize(sizeController: TextEditingController(), ingredients: []),
      );
    });
  }

  void _removeSize(int index) {
    final size = _sizes[index];

    setState(() {
      _sizes.removeAt(index);
    });

    size.dispose();
  }

  // ==========================================================
  // INGREDIENT MANAGEMENT
  // ==========================================================

  void _addIngredient(int sizeIndex) {
    setState(() {
      _sizes[sizeIndex].ingredients.add(
        _EditableIngredient(
          idController: TextEditingController(),
          nameController: TextEditingController(),
          amountController: TextEditingController(),
          unitController: TextEditingController(),
        ),
      );
    });
  }

  void _removeIngredient(int sizeIndex, int ingredientIndex) {
    final ingredient = _sizes[sizeIndex].ingredients[ingredientIndex];

    setState(() {
      _sizes[sizeIndex].ingredients.removeAt(ingredientIndex);
    });

    ingredient.dispose();
  }

  // ==========================================================
  // STEP MANAGEMENT
  // ==========================================================

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    final controller = _stepControllers[index];

    setState(() {
      _stepControllers.removeAt(index);
    });

    controller.dispose();
  }

  // ==========================================================
  // BUILD RECIPE
  // ==========================================================

  Recipe _buildRecipe() {
    final sizes = _sizes.map((editableSize) {
      final ingredients = editableSize.ingredients.map((editableIngredient) {
        return Ingredient(
          id: editableIngredient.idController.text.trim(),
          name: editableIngredient.nameController.text.trim(),
          amount: editableIngredient.amountController.text.trim(),
          unit: editableIngredient.unitController.text.trim(),
        );
      }).toList();

      return RecipeSize(
        size: editableSize.sizeController.text.trim(),
        ingredients: ingredients,
      );
    }).toList();

    final steps = _stepControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Recipe(
      id: widget.recipe.id,
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      group: _groupController.text.trim(),
      sizes: sizes,
      steps: steps,
    );
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  bool _validate() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showError('Recipe title cannot be empty.');
      return false;
    }

    final category = _categoryController.text.trim();

    if (category.isEmpty) {
      _showError('Category cannot be empty.');
      return false;
    }

    for (var i = 0; i < _sizes.length; i++) {
      final size = _sizes[i].sizeController.text.trim();

      if (size.isEmpty) {
        _showError('Size ${i + 1} must have a name.');
        return false;
      }

      for (var j = 0; j < _sizes[i].ingredients.length; j++) {
        final ingredient = _sizes[i].ingredients[j];

        final ingredientName = ingredient.nameController.text.trim();

        if (ingredientName.isEmpty) {
          _showError(
            'Ingredient ${j + 1} in $size '
            'must have a name.',
          );
          return false;
        }
      }
    }

    // Prevent duplicate size names.
    final sizeNames = _sizes
        .map((size) => size.sizeController.text.trim().toLowerCase())
        .where((size) => size.isNotEmpty)
        .toList();

    if (sizeNames.length != sizeNames.toSet().length) {
      _showError('Duplicate cup sizes are not allowed.');
      return false;
    }

    return true;
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_validate()) {
      return;
    }

    final updatedRecipe = _buildRecipe();

    setState(() {
      _isSaving = true;
    });

    try {
      await RecipeRepository.saveRecipe(widget.recipePath, updatedRecipe);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updatedRecipe);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError('Unable to save recipe.');

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInformation(),

                  const SizedBox(height: 24),

                  _buildSizesSection(),

                  const SizedBox(height: 24),

                  _buildStepsSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BASIC INFORMATION
  // ==========================================================

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _groupController,
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SIZES
  // ==========================================================

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Cup Sizes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            OutlinedButton.icon(
              onPressed: _addSize,
              icon: const Icon(Icons.add),
              label: const Text('Add Size'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_sizes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No sizes added yet.'),
            ),
          ),

        ..._sizes.asMap().entries.map((entry) {
          return _buildSizeEditor(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildSizeEditor(int sizeIndex, _EditableSize size) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: size.sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      hintText: 'Example: 12oz',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Remove size',
                  onPressed: () => _removeSize(sizeIndex),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                TextButton.icon(
                  onPressed: () => _addIngredient(sizeIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (size.ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No ingredients.'),
              ),

            ...size.ingredients.asMap().entries.map((entry) {
              return _buildIngredientEditor(sizeIndex, entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INGREDIENT EDITOR
  // ==========================================================

  Widget _buildIngredientEditor(
    int sizeIndex,
    int ingredientIndex,
    _EditableIngredient ingredient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ingredient.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient',
                    hintText: 'Example: Assam Black Tea',
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Remove ingredient',
                onPressed: () => _removeIngredient(sizeIndex, ingredientIndex),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ingredient.amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Example: 100',
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: ingredient.unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'Example: ml',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Keep the ID available for
          // existing recipes, but make
          // it optional.
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Advanced'),
            children: [
              TextField(
                controller: ingredient.idController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient ID',
                  helperText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREPARATION STEPS
  // ==========================================================

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Preparation Steps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            OutlinedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_stepControllers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No preparation steps.'),
            ),
          ),

        ..._stepControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: CircleAvatar(
                      radius: 14,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Preparation step',
                        hintText: 'Describe what to do',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Remove step',
                    onPressed: () => _removeStep(index),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================
  // BOTTOM BAR
  // ==========================================================

  Widget _buildBottomBar() {
    return Material(
      elevation: 8,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// EDITABLE SIZE
// ==================================================================

class _EditableSize {
  final TextEditingController sizeController;
  final List<_EditableIngredient> ingredients;

  _EditableSize({required this.sizeController, required this.ingredients});

  factory _EditableSize.fromRecipeSize(RecipeSize size) {
    return _EditableSize(
      sizeController: TextEditingController(text: size.size),
      ingredients: size.ingredients.map((ingredient) {
        return _EditableIngredient.fromIngredient(ingredient);
      }).toList(),
    );
  }

  void dispose() {
    sizeController.dispose();

    for (final ingredient in ingredients) {
      ingredient.dispose();
    }
  }
}

// ==================================================================
// EDITABLE INGREDIENT
// ==================================================================

class _EditableIngredient {
  final TextEditingController idController;

  final TextEditingController nameController;

  final TextEditingController amountController;

  final TextEditingController unitController;

  _EditableIngredient({
    required this.idController,
    required this.nameController,
    required this.amountController,
    required this.unitController,
  });

  factory _EditableIngredient.fromIngredient(Ingredient ingredient) {
    return _EditableIngredient(
      idController: TextEditingController(text: ingredient.id),
      nameController: TextEditingController(text: ingredient.name),
      amountController: TextEditingController(text: ingredient.amount),
      unitController: TextEditingController(text: ingredient.unit),
    );
  }

  void dispose() {
    idController.dispose();
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
  }
}
