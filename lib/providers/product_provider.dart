import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await ApiService.fetchProducts(); // <-- sửa lại tên hàm ở đây
    notifyListeners();
  }

  void addToFavorites(Product product) {
    // tuỳ vào logic bạn muốn lưu
    notifyListeners();
  }

  void addToCart(Product product) {
    // tuỳ vào logic bạn muốn lưu
    notifyListeners();
  }
}
