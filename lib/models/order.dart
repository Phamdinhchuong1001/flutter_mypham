import 'cart_item.dart';

class OrderProduct {
  final int orderId;
  final int userId;
  final String nameCustomer;
  final String status;
  final double totalPrice;
  final List<CartItemModel> listCartItem;
  final DateTime createdAt;
  final String address;
  final String payment;
  final double deliveryFee;
  final double orderDiscount;
  final String note;

  OrderProduct({
    required this.orderId,
    required this.userId,
    required this.nameCustomer,
    required this.status,
    required this.totalPrice,
    required this.listCartItem,
    required this.createdAt,
    required this.address,
    required this.payment,
    required this.deliveryFee,
    required this.orderDiscount,
    required this.note,
  });

factory OrderProduct.fromJson(Map<String, dynamic> json) {
  return OrderProduct(
    orderId: json['orderId'] ?? 0,
    userId: json['userId'] ?? 0,
    nameCustomer: json['nameCustomer'] ?? '',
    status: json['status'] ?? '',
    totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    listCartItem: (json['listCartItem'] as List<dynamic>?)
            ?.map((item) => CartItemModel.fromJson(item))
            .toList() ?? [],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    address: json['address'] ?? '',
    payment: json['payment'] ?? '',
    deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
    orderDiscount: (json['orderDiscount'] ?? 0).toDouble(),
    note: json['note'] ?? '',
  );
}




  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'nameCustomer': nameCustomer,
      'status': status,
      'totalPrice': totalPrice,
      'listCartItem': listCartItem.map((item) => {
            'id': item.id,
            'title': item.title,
            'description': item.description,
            'price': item.price,
            'images': item.images,
            'quantity': item.quantity,
          }).toList(),
      'createdAt': createdAt.toIso8601String(),
      'address': address,
      'payment': payment,
      'deliveryFee': deliveryFee,
      'orderDiscount': orderDiscount,
      'note': note,
    };
  }
}
