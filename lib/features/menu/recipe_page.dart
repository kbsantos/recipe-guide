import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bigger_brew_barista/models/recipe.dart';
import 'package:bigger_brew_barista/models/recipe_size.dart';
import 'package:bigger_brew_barista/repositories/recipe_repository.dart';
import 'package:bigger_brew_barista/services/favorite_service.dart';
import 'package:bigger_brew_barista/services/recent_service.dart';
import 'package:bigger_brew_barista/shared/widgets/base_page.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/app_loading.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/empty_state.dart';

import '../barista/barista_mode_page.dart';
import '../recipe_editor/recipe_editor_page.dart';

class RecipePage extends StatefulWidget {
  final String recipePath;
  final String? imagePath;

  const RecipePage({super.key, required this.recipePath, this.imagePath});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Future<Recipe> _recipeFuture;

  final _favoriteService = FavoriteService.instance;
  final _recentService = RecentService.instance;

  RecipeSize? _selectedSize;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _recipeFuture = RecipeRepository.loadRecipe(widget.recipePath);

    _recipeFuture.then(
      (_) => _recentService.record(widget.recipePath),
      onError: (_) {},
    );

    _favoriteService.load();
    _favoriteService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ==========================================================
  // FAVORITE
  // ==========================================================

  void _toggleFavorite() {
    _favoriteService.toggle(widget.recipePath);
  }

  // ==========================================================
  // EDIT RECIPE
  // ==========================================================

  Future<void> _openEditor(Recipe recipe) async {
    final selectedSizeName = _selectedSize?.size;

    final updatedRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(
        builder: (_) =>
            RecipeEditorPage(recipe: recipe, recipePath: widget.recipePath),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _recipeFuture = RecipeRepository.loadRecipe(widget.recipePath);
    });

    if (updatedRecipe != null && selectedSizeName != null) {
      final matchingSizes = updatedRecipe.sizes.where(
        (size) => size.size == selectedSizeName,
      );

      if (matchingSizes.isNotEmpty) {
        setState(() {
          _selectedSize = matchingSizes.first;
        });

        return;
      }
    }

    if (updatedRecipe != null && updatedRecipe.sizes.isNotEmpty) {
      setState(() {
        _selectedSize = updatedRecipe.sizes.first;
      });
    }
  }

  // ==========================================================
  // BARISTA MODE
  // ==========================================================

  void _startBaristaMode(Recipe recipe) {
    if (recipe.steps.isEmpty || _selectedSize == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BaristaModePage(
          recipeTitle: recipe.title,

          // IMPORTANT:
          // The current BaristaModePage requires the selected size.
          size: _selectedSize!,

          steps: recipe.steps,
        ),
      ),
    );
  }

  // ==========================================================
  // COPY RECIPE
  // ==========================================================

  Future<void> _copyRecipe(Recipe recipe) async {
    final json = const JsonEncoder.withIndent('  ').convert(recipe.toJson());

    await Clipboard.setData(ClipboardData(text: json));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // STEP ICON
  // ==========================================================

  IconData _stepIcon(String step) {
    final text = step.toLowerCase();

    if (text.contains('brew') ||
        text.contains('tea') ||
        text.contains('espresso') ||
        text.contains('coffee')) {
      return Icons.coffee_outlined;
    }

    if (text.contains('ice')) {
      return Icons.ac_unit_outlined;
    }

    if (text.contains('shake') ||
        text.contains('mix') ||
        text.contains('stir')) {
      return Icons.blender_outlined;
    }

    if (text.contains('pour') ||
        text.contains('transfer') ||
        text.contains('serve')) {
      return Icons.local_drink_outlined;
    }

    if (text.contains('cream') ||
        text.contains('creamer') ||
        text.contains('milk')) {
      return Icons.water_drop_outlined;
    }

    if (text.contains('syrup') ||
        text.contains('sauce') ||
        text.contains('fructose') ||
        text.contains('sugar')) {
      return Icons.opacity_outlined;
    }

    if (text.contains('powder') ||
        text.contains('matcha') ||
        text.contains('chocolate')) {
      return Icons.spa_outlined;
    }

    if (text.contains('finish') || text.contains('ready')) {
      return Icons.check_circle_outline;
    }

    return Icons.radio_button_checked;
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _buildLoading() {
    return const BasePage(
      title: 'Recipe',
      subtitle: 'Loading...',
      child: AppLoading(label: 'Loading recipe...'),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildError() {
    return BasePage(
      title: 'Recipe',
      subtitle: widget.recipePath,
      child: const EmptyState(
        title: 'This recipe could not be loaded.',
        icon: Icons.error_outline,
      ),
    );
  }

  // ==========================================================
  // TOP ACTION BUTTON
  // ==========================================================

  Widget _topActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool active = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: active
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(9),
          minimumSize: const Size(42, 42),
        ),
        icon: Icon(icon, size: 21),
      ),
    );
  }

  // ==========================================================
  // RECIPE HEADER
  // ==========================================================

  Widget _buildRecipeHeader(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selectedSize = _selectedSize!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 850;

          return isCompact
              ? _buildCompactHeader(context, recipe, selectedSize)
              : _buildWideHeader(context, recipe, selectedSize);
        },
      ),
    );
  }

  Widget _buildWideHeader(
    BuildContext context,
    Recipe recipe,
    RecipeSize selectedSize,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        _buildRecipeIcon(context),
        const SizedBox(width: 18),

        Expanded(flex: 3, child: _buildRecipeTitle(context, recipe)),

        Container(width: 1, height: 72, color: scheme.outlineVariant),

        const SizedBox(width: 10),

        Expanded(
          flex: 4,
          child: _buildSummaryMetrics(context, selectedSize, recipe),
        ),
      ],
    );
  }

  Widget _buildCompactHeader(
    BuildContext context,
    Recipe recipe,
    RecipeSize selectedSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRecipeIcon(context),
            const SizedBox(width: 14),
            Expanded(child: _buildRecipeTitle(context, recipe)),
          ],
        ),

        const SizedBox(height: 18),

        _buildSummaryMetrics(context, selectedSize, recipe),
      ],
    );
  }

  Widget _buildRecipeIcon(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: widget.imagePath != null
          ? ClipOval(
              child: Image.asset(
                widget.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Icon(
                    Icons.local_cafe_outlined,
                    size: 36,
                    color: scheme.onPrimaryContainer,
                  );
                },
              ),
            )
          : Icon(
              Icons.local_cafe_outlined,
              size: 36,
              color: scheme.onPrimaryContainer,
            ),
    );
  }

  Widget _buildRecipeTitle(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          recipe.category.isEmpty
              ? recipe.group
              : '${recipe.category} • ${recipe.group}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMetrics(
    BuildContext context,
    RecipeSize selectedSize,
    Recipe recipe,
  ) {
    return Row(
      children: [
        Expanded(
          child: _summaryMetric(
            context,
            icon: Icons.local_drink_outlined,
            value: selectedSize.size,
            label: 'Size',
          ),
        ),

        _metricDivider(context),

        Expanded(
          child: _summaryMetric(
            context,
            icon: Icons.inventory_2_outlined,
            value: '${selectedSize.ingredients.length}',
            label: 'Ingredients',
          ),
        ),

        _metricDivider(context),

        Expanded(
          child: _summaryMetric(
            context,
            icon: Icons.format_list_numbered,
            value: '${recipe.steps.length}',
            label: 'Steps',
          ),
        ),
      ],
    );
  }

  Widget _metricDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 58,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _summaryMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // CUP SIZE
  // ==========================================================

  Widget _buildCupSizeSection(BuildContext context, Recipe recipe) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Cup Size'),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: recipe.sizes.map((size) {
              final selected = _selectedSize == size;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _cupSizeButton(
                  context,
                  size: size,
                  selected: selected,
                  onPressed: () {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _cupSizeButton(
    BuildContext context, {
    required RecipeSize size,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? scheme.primaryContainer : scheme.surface,
        foregroundColor: selected
            ? scheme.onPrimaryContainer
            : scheme.onSurface,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outline,
          width: selected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            const Icon(Icons.check, size: 19),
            const SizedBox(width: 7),
          ],
          Text(
            size.size,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INGREDIENTS
  // ==========================================================

  Widget _buildIngredientsSection(
    BuildContext context,
    RecipeSize selectedSize,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Ingredients'),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: selectedSize.ingredients.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No ingredients available.'),
                )
              : Column(
                  children: selectedSize.ingredients
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildIngredientRow(
                          context,
                          entry.value,
                          isLast:
                              entry.key == selectedSize.ingredients.length - 1,
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(
    BuildContext context,
    dynamic ingredient, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final amount = ingredient.amount.toString().trim();
    final unit = ingredient.unit.toString().trim();

    final quantity = [
      amount,
      unit,
    ].where((value) => value.isNotEmpty).join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ingredient.name.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              quantity.isEmpty ? '—' : quantity,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREPARATION
  // ==========================================================

  Widget _buildPreparationSection(BuildContext context, Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Preparation'),

        const SizedBox(height: 14),

        if (recipe.steps.isEmpty)
          const EmptyState(
            title: 'No preparation steps available.',
            icon: Icons.receipt_long_outlined,
          )
        else
          _buildPreparationTimeline(context, recipe.steps),
      ],
    );
  }

  Widget _buildPreparationTimeline(BuildContext context, List<String> steps) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = steps.length <= 5 ? 150.0 : 125.0;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;

                return SizedBox(
                  width: itemWidth,
                  child: _buildPreparationStep(
                    context,
                    index: index,
                    step: step,
                    isLast: index == steps.length - 1,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreparationStep(
    BuildContext context, {
    required int index,
    required String step,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _stepIcon(step),
                    size: 29,
                    color: scheme.onPrimaryContainer,
                  ),
                ),

                Positioned(
                  left: -4,
                  top: -7,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (!isLast)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 2,
                  color: scheme.outlineVariant,
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            step,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        // ------------------------------------------------------
        // LOADING
        // ------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        if (snapshot.hasError) {
          return _buildError();
        }

        // ------------------------------------------------------
        // RECIPE
        // ------------------------------------------------------

        final recipe = snapshot.data;

        if (recipe == null) {
          return BasePage(
            title: 'Recipe',
            subtitle: widget.recipePath,
            child: const EmptyState(
              title: 'No recipe data was found.',
              icon: Icons.local_drink_outlined,
            ),
          );
        }

        if (recipe.sizes.isEmpty) {
          return BasePage(
            title: recipe.title,
            subtitle: recipe.category,
            child: const EmptyState(
              title: 'No cup sizes are available for this recipe.',
              icon: Icons.local_drink_outlined,
            ),
          );
        }

        _selectedSize ??= recipe.sizes.first;

        final isFavorite = _favoriteService.isFavorite(widget.recipePath);

        // ------------------------------------------------------
        // FINAL RECIPE PAGE
        // ------------------------------------------------------

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recipe'),
            centerTitle: false,

            // ==================================================
            // TOP-RIGHT ICON ACTIONS
            // ==================================================
            actions: [
              // START PREPARATION
              _topActionButton(
                icon: Icons.play_arrow_rounded,
                tooltip: 'Start Preparation',
                onPressed: recipe.steps.isEmpty
                    ? null
                    : () => _startBaristaMode(recipe),
              ),

              // FAVORITE
              _topActionButton(
                icon: isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_rounded,
                tooltip: isFavorite ? 'Remove Favorite' : 'Add Favorite',
                active: isFavorite,
                onPressed: _toggleFavorite,
              ),

              // COPY RECIPE
              _topActionButton(
                icon: Icons.content_copy_outlined,
                tooltip: 'Copy Recipe',
                onPressed: () => _copyRecipe(recipe),
              ),

              // EDIT RECIPE
              _topActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit Recipe',
                onPressed: () => _openEditor(recipe),
              ),

              const SizedBox(width: 8),
            ],
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // RECIPE HEADER
                  // ==================================================
                  _buildRecipeHeader(context, recipe),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CUP SIZE
                  // ==================================================
                  _buildCupSizeSection(context, recipe),

                  const SizedBox(height: 24),

                  const Divider(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // INGREDIENTS
                  // ==================================================
                  _buildIngredientsSection(context, _selectedSize!),

                  const SizedBox(height: 28),

                  const Divider(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // PREPARATION
                  // ==================================================
                  _buildPreparationSection(context, recipe),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
