class CartItemModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
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
      images: List<String>.from(json['images']),
      quantity: int.parse(json['quantity'].toString()),
    );
  }
}
