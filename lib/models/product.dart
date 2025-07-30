class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String image;
  int quantity; // ✅ thêm field quantity

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.quantity = 1, // ✅ mặc định là 1 khi thêm vào giỏ hàng
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'quantity': quantity, // ✅ đưa quantity vào JSON nếu cần
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      quantity: json['quantity'] ?? 1, // ✅ đọc quantity nếu có
    );
  }
}
