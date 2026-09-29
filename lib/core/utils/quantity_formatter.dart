String formatRecipeAmount(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;

  final number = double.tryParse(trimmed);
  if (number == null || !number.isFinite) {
    return trimmed;
  }

  // Recipe quantities that are whole numbers should not show
  // database precision such as 10.0000 or 200.0000.
  if (number == number.roundToDouble()) {
    return number.toInt().toString();
  }

  // Preserve meaningful fractional quantities while removing
  // unnecessary trailing zeroes.
  final normalized = number.toString();
  return normalized.replaceFirst(RegExp(r'\.0+$'), '');
}
