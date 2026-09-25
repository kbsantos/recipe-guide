import 'package:flutter/material.dart';

import 'package:bigger_brew_barista/core/navigation/app_router.dart';
import 'package:bigger_brew_barista/features/menu/recipe_page.dart';
import 'package:bigger_brew_barista/models/menu_item.dart';
import 'package:bigger_brew_barista/repositories/menu_repository.dart';
import 'package:bigger_brew_barista/services/recent_service.dart';
import 'package:bigger_brew_barista/shared/widgets/base_page.dart';
import 'package:bigger_brew_barista/shared/widgets/menu/drink_card.dart';

class RecentDrinksPage extends StatefulWidget {
  const RecentDrinksPage({super.key, this.recentService});

  final RecentService? recentService;

  @override
  State<RecentDrinksPage> createState() => _RecentDrinksPageState();
}

class _RecentDrinksPageState extends State<RecentDrinksPage> {
  late final RecentService _recentService;

  final Map<String, MenuItem> _itemsByPath = {
    for (final item
        in MenuRepository.categories
            .expand((category) => category.groups)
            .expand((group) => group.items))
      item.recipePath: item,
  };

  @override
  void initState() {
    super.initState();

    _recentService = widget.recentService ?? RecentService.instance;

    _recentService.load();
    _recentService.addListener(_onRecentsChanged);
  }

  @override
  void dispose() {
    _recentService.removeListener(_onRecentsChanged);

    super.dispose();
  }

  // ==========================================================
  // RECENT CHANGES
  // ==========================================================

  void _onRecentsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================
  // RECENT ITEMS
  // ==========================================================

  List<MenuItem> get _recentItems {
    return _recentService.recentRecipePaths
        .map((recipePath) => _itemsByPath[recipePath])
        .whereType<MenuItem>()
        .toList(growable: false);
  }

  // ==========================================================
  // CLEAR RECENT
  // ==========================================================

  Future<void> _clearRecent() async {
    await _recentService.clear();
  }

  // ==========================================================
  // OPEN RECIPE
  // ==========================================================

  Future<void> _openRecipe(BuildContext context, MenuItem item) async {
    await AppRouter.push(
      context,
      RecipePage(recipePath: item.recipePath, imagePath: item.imagePath),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final recentItems = _recentItems;

    return BasePage(
      title: 'Recent Drinks',
      subtitle: 'Your recently opened recipes',

      // ========================================================
      // PAGE ACTIONS
      // ========================================================
      actions: [
        if (recentItems.isNotEmpty)
          IconButton(
            tooltip: 'Clear recent drinks',
            icon: const Icon(Icons.clear_all),
            onPressed: _clearRecent,
          ),
      ],

      // ========================================================
      // CONTENT
      // ========================================================
      child: recentItems.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),

              itemCount: recentItems.length,

              separatorBuilder: (context, index) => const SizedBox(height: 10),

              itemBuilder: (context, index) {
                final item = recentItems[index];

                return DrinkCard(
                  title: item.title,
                  subtitle: 'Recently viewed',
                  imagePath: item.imagePath,

                  onTap: () => _openRecipe(context, item),
                );
              },
            ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // --------------------------------------------------
            // ICON
            // --------------------------------------------------
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 42,
                color: scheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // TITLE
            // --------------------------------------------------
            Text(
              'No recent drinks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // --------------------------------------------------
            // DESCRIPTION
            // --------------------------------------------------
            Text(
              'Drinks you open will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
