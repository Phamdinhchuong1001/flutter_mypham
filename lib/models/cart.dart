import 'package:flutter_appmypham/models/cart_item.dart';
class Cart {
  final String cartId;
  final List<CartItem> cartItem;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.cartId,
    required this.cartItem,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'] ?? '',
      cartItem: (json['cartItem'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'cartItem': cartItem.map((item) => item.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
