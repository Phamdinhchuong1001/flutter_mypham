import 'package:dio/dio.dart';
import '../models/product.dart';

class AdminProductService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://172.20.10.5:3000/api/products';



Future<int> getTotalProductsCount() async {
  try {
    final response = await _dio.get('$_baseUrl/count');
    final total = response.data['totalProducts']; // ✅ sửa ở đây
    return total;
  } catch (e) {
    print('❌ [getTotalProductsCount] Lỗi lấy tổng sản phẩm: $e');
    return 0;
  }
}




  /// 📦 Lấy tất cả sản phẩm
Future<List<Product>> getProducts() async {
  try {
    final response = await _dio.get(_baseUrl);
    print('📥 [getProducts] Dữ liệu từ server: ${response.data}');

    final List data = response.data;
    return data.map((e) => Product.fromJson(e)).toList();
  } catch (e) {
    print('❌ [getProducts] Lỗi lấy danh sách sản phẩm: $e');
    return [];
  }
}


  /// 🔍 Lấy sản phẩm theo ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      print('❌ [getProductById] Lỗi lấy sản phẩm $id: $e');
      return null;
    }
  }

  /// ➕ Thêm sản phẩm mới
  Future<bool> addProduct(Product product) async {
  try {
    final response = await _dio.post(_baseUrl, data: {
      "name": product.name,
      "image": product.image,
      "description": product.description,
      "price": product.price,
    });

    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    print('❌ [addProduct] Lỗi thêm sản phẩm: $e');
    return false;
  }
}


  /// 🔄 Cập nhật sản phẩm
  Future<bool> updateProduct(Product product) async {
        print('📤 Gửi yêu cầu cập nhật sản phẩm: ${product.toJson()}');
    try {
      final response = await _dio.put('$_baseUrl/${product.id}', data: product.toJson());
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [updateProduct] Lỗi cập nhật sản phẩm: $e');
      return false;
    }
  }

  /// 🗑️ Xoá sản phẩm
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('$_baseUrl/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [deleteProduct] Lỗi xóa sản phẩm $id: $e');
      return false;
    }
  }

  /// 🔍 Lọc & sắp xếp sản phẩm
  Future<List<Product>> filterAndSortProducts({
    String? searchQuery,
    int? categoryId,
    String sortOption = 'Tên (A-Z)',
  }) async {
    try {
      List<Product> products = await getProducts();

      // Filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        products = products
            .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      // Sort
      switch (sortOption) {
        case 'Tên (A-Z)':
          products.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Tên (Z-A)':
          products.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Giá (Thấp đến Cao)':
          products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Giá (Cao đến Thấp)':
          products.sort((a, b) => b.price.compareTo(a.price));
          break;
      }

      return products;
    } catch (e) {
      print('❌ [filterAndSort] Lỗi lọc/sắp xếp sản phẩm: $e');
      return [];
    }
  }

  /// 🏆 Lấy sản phẩm bán chạy
  Future<List<Product>> getTopSellingProducts() async {
    try {
      final response = await _dio.get('$_baseUrl/top-selling');
      final List data = response.data;
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print('❌ [top-selling] Lỗi lấy sản phẩm bán chạy: $e');
      return [];
    }
  }

  /// 📋 Danh sách tiêu chí sắp xếp
  List<String> getSortOptions() {
    return [
      'Tên (A-Z)',
      'Tên (Z-A)',
      'Giá (Thấp đến Cao)',
      'Giá (Cao đến Thấp)',
    ];
  }
  
}
