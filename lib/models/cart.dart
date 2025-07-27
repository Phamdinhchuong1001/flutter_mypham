import 'package:flutter_appmypham/models/cart_item.dart';

class Cart {
  final String cartId;
  final List<CartItemModel> cartItems;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.cartId,
    required this.cartItems,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'] ?? '',
      cartItems: (json['cartItems'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
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
      'cartItems': cartItems.map((item) => {
            'id': item.id,
            'title': item.title,
            'description': item.description,
            'price': item.price,
            'images': item.images,
            'quantity': item.quantity,
          }).toList(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
