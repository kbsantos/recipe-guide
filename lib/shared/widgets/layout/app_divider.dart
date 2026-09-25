import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final double verticalPadding;

  const AppDivider({super.key, this.verticalPadding = 24});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
