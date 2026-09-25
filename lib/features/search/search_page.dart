import 'package:bigger_brew_barista/core/navigation/app_router.dart';
import 'package:bigger_brew_barista/features/menu/recipe_page.dart';
import 'package:bigger_brew_barista/models/search_result.dart';
import 'package:bigger_brew_barista/services/search_service.dart';
import 'package:bigger_brew_barista/shared/widgets/base_page.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/app_loading.dart';
import 'package:bigger_brew_barista/shared/widgets/layout/empty_state.dart';
import 'package:bigger_brew_barista/shared/widgets/menu/drink_card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _searchService = SearchService();

  Future<List<SearchResult>>? _resultsFuture;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();

    setState(() {
      _query = query;
      _resultsFuture = query.isEmpty ? null : _searchService.search(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Search Drinks',
      subtitle: 'Search by drink, category, group, or ingredient',
      actions: [
        if (_query.isNotEmpty)
          IconButton(
            onPressed: _clearSearch,
            tooltip: 'Clear search',
            icon: const Icon(Icons.clear),
          ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Try “dark chocolate” or “creamer”',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_resultsFuture == null) {
      return const EmptyState(
        title: 'Start typing to find a drink or recipe ingredient.',
        icon: Icons.search,
      );
    }

    return FutureBuilder<List<SearchResult>>(
      future: _resultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoading(label: 'Searching recipes...');
        }

        if (snapshot.hasError) {
          return const EmptyState(
            title: 'Search is unavailable right now.',
            icon: Icons.error_outline,
          );
        }

        final results = snapshot.data ?? const <SearchResult>[];

        if (results.isEmpty) {
          return const EmptyState(
            title: 'No drinks match that search.',
            icon: Icons.search_off,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final result = results[index];

            return DrinkCard(
              title: result.item.title,
              subtitle: '${result.category} • ${result.group}',
              imagePath: result.item.imagePath,
              onTap: () => AppRouter.push(
                context,
                RecipePage(
                  recipePath: result.item.recipePath,
                  imagePath: result.item.imagePath,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
