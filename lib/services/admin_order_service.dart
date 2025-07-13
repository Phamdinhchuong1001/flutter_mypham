import 'package:dio/dio.dart';
import '../models/order.dart';

class AdminOrderService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api/orders';

  Future<List<OrderProduct>> getOrders() async {
    try {
      final response = await _dio.get(_baseUrl);
      final List data = response.data;
      return data.map((e) => OrderProduct.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getting orders: $e');
      return [];
    }
  }

  Future<OrderProduct?> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('$_baseUrl/$orderId');
      return OrderProduct.fromJson(response.data);
    } catch (e) {
      print('❌ Error getting order by id: $e');
      return null;
    }
  }

  Future<List<OrderProduct>> getUserOrders(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/user/$userId');
      final List data = response.data;
      return data.map((e) => OrderProduct.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getting user orders: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _dio.put('$_baseUrl/$orderId/status', data: {'status': status});
      return true;
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  Future<bool> rateOrder(String orderId, int rating, String? feedback) async {
    try {
      await _dio.put('$_baseUrl/$orderId/rate', data: {
        'ratedBar': rating,
        'feedback': feedback,
      });
      return true;
    } catch (e) {
      print('❌ Error rating order: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getOrderAnalytics() async {
    try {
      final response = await _dio.get('$_baseUrl/analytics');
      return response.data;
    } catch (e) {
      print('❌ Error getting analytics: $e');
      return {};
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Giao thành công';
      case 'cancelled':
        return 'Đơn hàng hủy';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'delivering':
        return 'Đang giao';
      case 'pending':
        return 'Chờ xác nhận';
      default:
        return 'Không xác định';
    }
  }
}
