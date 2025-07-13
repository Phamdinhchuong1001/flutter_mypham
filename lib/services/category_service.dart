import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api/categories';

  /// Lấy tất cả danh mục
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(_baseUrl);
      final List data = response.data;
      return data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print('❌ [getCategories] Lỗi lấy danh sách danh mục: $e');
      return [];
    }
  }
}
