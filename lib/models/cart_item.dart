class CartItem {
  final String cartItemId;
  final String productId;
  final String sizeId;
  final num unitPrice;
  final int quantity;
  final num totalPrice;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.sizeId,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse từ JSON trả về từ API Node.js
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cartItemId'] ?? '',
      productId: json['productId'] ?? '',
      sizeId: json['sizeId'] ?? '',
      unitPrice: json['unitPrice'] ?? 0,
      quantity: json['quantity'] ?? 1,
      totalPrice: json['totalPrice'] ?? 0,
      userId: json['userId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Dùng để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'productId': productId,
      'sizeId': sizeId,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
