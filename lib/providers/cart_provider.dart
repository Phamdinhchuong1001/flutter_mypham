import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _cartItems = [];

  List<Product> get cartItems => _cartItems;

  /// Thêm sản phẩm vào giỏ hàng. Nếu đã có thì tăng quantity.
  void addToCart(Product product) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity += 1;
    } else {
      // Đảm bảo mỗi sản phẩm thêm mới có quantity = 1
      product.quantity = 1;
      _cartItems.add(product);
    }
    notifyListeners();
  }

  /// Tăng số lượng sản phẩm
  void increaseQuantity(Product product) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity += 1;
      notifyListeners();
    }
  }

  /// Giảm số lượng sản phẩm
  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1 && _cartItems[index].quantity > 1) {
      _cartItems[index].quantity -= 1;
      notifyListeners();
    }
  }

  /// Xoá sản phẩm khỏi giỏ hàng
  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  /// Xoá toàn bộ giỏ hàng
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Tổng tiền = sum(price * quantity)
  double get totalPrice {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// Tổng số lượng sản phẩm
  int get totalQuantity {
    return _cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }
}
