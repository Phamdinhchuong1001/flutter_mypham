import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  final String baseUrl = 'http://172.20.10.5:3000/api/orders';

  /// Lấy tất cả đơn hàng (nếu bạn vẫn cần dùng)
 Future<List<OrderProduct>> fetchOrders() async {
  final response = await http.get(Uri.parse(baseUrl));

  // 🟡 In log response để kiểm tra JSON thực tế
  print('📥 Response từ API: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(response.body); // ✅ response.body là một List, KHÔNG có key 'data'

    // 🟡 In thêm JSON đã decode
    print('📥 JSON đã decode: $json');

    return json.map((item) => OrderProduct.fromJson(item)).toList();
  } else {
    throw Exception('Lỗi khi lấy danh sách đơn hàng');
  }
}




  /// Lấy đơn hàng theo userId (đã thêm)
  Future<List<OrderProduct>> fetchOrdersByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderProduct.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi lấy đơn hàng theo userId');
    }
  }
}
