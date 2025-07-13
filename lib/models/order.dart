// lib/models/order.dart

class OrderProduct {
  final String orderId;
  final String userId;
  final String status;
  final double totalPrice;
  final List<CartItem> listCartItem;

  OrderProduct({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.listCartItem,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      listCartItem: (json['listCartItem'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'status': status,
      'totalPrice': totalPrice,
      'listCartItem': listCartItem.map((item) => item.toJson()).toList(),
    };
  }
}

class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
