import 'package:bigger_brew_barista/models/recipe_size.dart';
import 'package:flutter/material.dart';

class BaristaModePage extends StatefulWidget {
  final String recipeTitle;
  final RecipeSize size;
  final List<String> steps;

  const BaristaModePage({
    super.key,
    required this.recipeTitle,
    required this.size,
    required this.steps,
  });

  @override
  State<BaristaModePage> createState() => _BaristaModePageState();
}

class _BaristaModePageState extends State<BaristaModePage> {
  int _currentStep = 0;

  // ==========================================================
  // CURRENT STEP
  // ==========================================================

  String get _currentStepText {
    if (widget.steps.isEmpty) {
      return '';
    }

    return widget.steps[_currentStep];
  }

  // ==========================================================
  // FIND INGREDIENT FOR CURRENT STEP
  // ==========================================================

  IngredientInfo? _findIngredientForStep(String step) {
    final stepText = step.toLowerCase();

    for (final ingredient in widget.size.ingredients) {
      final ingredientName = ingredient.name.trim();

      if (ingredientName.isEmpty) {
        continue;
      }

      final name = ingredientName.toLowerCase();

      if (stepText.contains(name)) {
        return IngredientInfo(
          name: ingredient.name,
          amount: ingredient.amount,
          unit: ingredient.unit,
        );
      }
    }

    return null;
  }

  // ==========================================================
  // CURRENT INGREDIENT
  // ==========================================================

  IngredientInfo? get _currentIngredient {
    return _findIngredientForStep(_currentStepText);
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

    if (text.contains('pour') || text.contains('transfer')) {
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

    if (text.contains('serve') ||
        text.contains('finish') ||
        text.contains('ready')) {
      return Icons.check_circle_outline;
    }

    return Icons.radio_button_checked;
  }

  // ==========================================================
  // NEXT
  // ==========================================================

  void _nextStep() {
    if (_currentStep >= widget.steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  // ==========================================================
  // BACK
  // ==========================================================

  void _previousStep() {
    if (_currentStep == 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  // ==========================================================
  // AMOUNT DISPLAY
  // ==========================================================

  Widget _buildAmountCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final ingredient = _currentIngredient;

    if (ingredient == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 32, color: scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'No ingredient amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final amount = ingredient.amount.trim();
    final unit = ingredient.unit.trim();

    String amountText;

    if (amount.isEmpty && unit.isEmpty) {
      amountText = 'Amount not specified';
    } else if (unit.isEmpty) {
      amountText = amount;
    } else if (amount.isEmpty) {
      amountText = unit;
    } else {
      amountText = '$amount $unit';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ingredient name
          Text(
            ingredient.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // Amount
          Text(
            amountText,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'REQUIRED AMOUNT',
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PROGRESS
  // ==========================================================

  Widget _buildProgress(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final progress = widget.steps.isEmpty
        ? 0.0
        : (_currentStep + 1) / widget.steps.length;

    return Column(
      children: [
        Text(
          'Step ${_currentStep + 1} of ${widget.steps.length}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // MAIN STEP CARD
  // ==========================================================

  Widget _buildStepCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step icon
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _stepIcon(_currentStepText),
              size: 40,
              color: scheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 22),

          // Step title
          Text(
            _currentStepText,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Amount
          _buildAmountCard(context),
        ],
      ),
    );
  }

  // ==========================================================
  // NAVIGATION BUTTONS
  // ==========================================================

  Widget _buildNavigationButtons(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirstStep ? null : _previousStep,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: FilledButton.icon(
            onPressed: _nextStep,
            icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
            label: Text(isLastStep ? 'Finish' : 'Next'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barista Mode')),
        body: const Center(child: Text('No preparation steps available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Barista Mode')),

      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // RECIPE TITLE
            // ====================================================
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                widget.recipeTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ====================================================
            // PROGRESS
            // ====================================================
            _buildProgress(context),

            const SizedBox(height: 32),

            // ====================================================
            // STEP
            // ====================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(child: _buildStepCard(context)),
                ),
              ),
            ),

            // ====================================================
            // NAVIGATION
            // ====================================================
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// INGREDIENT INFO
// ==========================================================

class IngredientInfo {
  final String name;
  final String amount;
  final String unit;

  const IngredientInfo({
    required this.name,
    required this.amount,
    required this.unit,
  });
}
