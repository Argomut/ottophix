class Item {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imagePath;

  Item({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
}
