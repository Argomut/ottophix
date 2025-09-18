import 'models/item.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  final List<Item> _items = [];

  CartManager._internal();

  factory CartManager() {
    return _instance;
  }

  List<Item> get items => _items;

  void addItem(Item item) {
    _items.add(item);
  }

  void removeItem(Item item) {
    _items.remove(item);
  }

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price);
}