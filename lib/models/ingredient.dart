class Ingredient {
  final String id;
  final String name;
  final String amount;
  final String unit;

  const Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'amount': amount, 'unit': unit};
  }
}
