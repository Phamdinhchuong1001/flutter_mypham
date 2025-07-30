class CartItemModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String images; // 🟡 đổi từ List<String> → String
  final int quantity;

  CartItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      images: json['images'], // 🟢 không cần List.from nữa
      quantity: int.parse(json['quantity'].toString()),
    );
  }
}
