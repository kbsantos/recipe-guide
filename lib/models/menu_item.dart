class MenuItem {
  final String id;
  final String title;
  final String recipePath;
  final String? imagePath;

  const MenuItem({
    required this.id,
    required this.title,
    required this.recipePath,
    this.imagePath,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      recipePath: json['recipePath'] ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'recipePath': recipePath,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }
}
