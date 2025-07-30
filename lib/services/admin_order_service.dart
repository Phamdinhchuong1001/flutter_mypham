import 'package:dio/dio.dart';
import '../models/order.dart';

class AdminOrderService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://172.20.10.5:3000/api/orders';

  /// 📦 Lấy tất cả đơn hàng
  Future<List<OrderProduct>> getOrders() async {
    try {
      final response = await _dio.get(_baseUrl);
      return (response.data as List)
          .map((e) => OrderProduct.fromJson(e))
          .toList();
    } catch (e) {
      print('❌ [getOrders] Lỗi khi lấy danh sách đơn hàng: $e');
      return [];
    }
  }

  /// 🔢 Lấy tổng số đơn hàng
  Future<int> getTotalOrders() async {
    try {
      final response = await _dio.get('$_baseUrl/count');
      return response.data['totalOrders'] ?? 0;
    } catch (e) {
      print('❌ [getTotalOrders] Lỗi khi lấy tổng số đơn hàng: $e');
      return 0;
    }
  }

  /// 💰 Lấy tổng doanh thu từ endpoint /revenue
  Future<double> getTotalRevenue() async {
    try {
      final response = await _dio.get('$_baseUrl/revenue');
      return (response.data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('❌ [getTotalRevenue] Lỗi khi lấy tổng doanh thu: $e');
      return 0.0;
    }
  }

  /// 📄 Lấy đơn hàng theo ID
  Future<OrderProduct?> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('$_baseUrl/$orderId');
      return OrderProduct.fromJson(response.data);
    } catch (e) {
      print('❌ [getOrderById] Lỗi khi lấy đơn hàng ID $orderId: $e');
      return null;
    }
  }

  /// 👤 Lấy đơn hàng của một user
  Future<List<OrderProduct>> getUserOrders(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/user/$userId');
      return (response.data as List)
          .map((e) => OrderProduct.fromJson(e))
          .toList();
    } catch (e) {
      print('❌ [getUserOrders] Lỗi khi lấy đơn hàng của user $userId: $e');
      return [];
    }
  }

  /// ✏️ Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _dio.put('$_baseUrl/$orderId/status', data: {
        'status': status,
      });
      return true;
    } catch (e) {
      print('❌ [updateOrderStatus] Lỗi cập nhật trạng thái đơn hàng $orderId: $e');
      return false;
    }
  }

  /// 🕔 Lấy 5 đơn hàng gần nhất
  Future<List<OrderProduct>> getRecentOrders() async {
    try {
      final List<OrderProduct> allOrders = await getOrders();
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allOrders.take(5).toList();
    } catch (e) {
      print('❌ [getRecentOrders] Lỗi khi lấy đơn hàng gần đây: $e');
      return [];
    }
  }

  /// 🇻🇳 Chuyển trạng thái sang tiếng Việt
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
