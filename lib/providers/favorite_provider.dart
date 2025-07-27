import 'package:flutter/material.dart';
import '../models/product.dart';


class FavoriteProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  void toggleFavorite(Product product) {
    final isExist = _favorites.any((item) => item.id == product.id);
    if (isExist) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void removeFavorite(Product product) {
    _favorites.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }
}
