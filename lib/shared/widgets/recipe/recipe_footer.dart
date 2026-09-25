import 'package:flutter/material.dart';

class RecipeFooter extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const RecipeFooter({
    super.key,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFavoritePressed,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(isFavorite ? 'Favorited' : 'Favorite'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy Recipe'),
          ),
        ),
      ],
    );
  }
}
