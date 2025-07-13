import '../models/category.dart';

class Product {
  final int id;
  final String name;
  final String image;
  final int preparationTime;
  final int calo;
  final num price;
  final String description;
  final bool status;
  final int categoryId;
  Category? category;
  List<ProductSize> sizes;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.preparationTime,
    required this.calo,
    required this.price,
    required this.description,
    required this.status,
    required this.categoryId,
    this.category,
    this.sizes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      preparationTime: json["preparationTime"] ?? 0,
      calo: json["calo"] ?? 0,
      price: json["price"] ?? 0,
      description: json["description"] ?? "",
      status: json["status"] ?? false,
      categoryId: json["categoryId"] ?? 0,
      sizes: (json["sizes"] as List?)?.map((e) => ProductSize.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "preparationTime": preparationTime,
      "calo": calo,
      "price": price,
      "description": description,
      "status": status,
      "categoryId": categoryId,
      "sizes": sizes.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductSize {
  final int sizeId;
  final String sizeName;
  final num extraPrice;

  ProductSize({
    required this.sizeId,
    required this.sizeName,
    required this.extraPrice,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      sizeId: json["sizeId"] ?? 0,
      sizeName: json["sizeName"] ?? "",
      extraPrice: json["extraPrice"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sizeId": sizeId,
      "sizeName": sizeName,
      "extraPrice": extraPrice,
    };
  }
}
