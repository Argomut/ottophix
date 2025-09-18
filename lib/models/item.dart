class Item {
  final int ? id;
  final String name;
  final double price;
  final String description;
  final String imagePath;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  });

  /// 从 JSON 创建 Item
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] is int ? json['id'] : null,
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? json['image_path'] ?? '',
    );
  }

  /// 转换为 JSON，用于保存到本地
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }
}