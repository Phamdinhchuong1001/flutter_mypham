import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderListScreen extends StatefulWidget {
  final int userId;

  const OrderListScreen({super.key, required this.userId});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<OrderProduct> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
  try {
    final allOrders = await OrderService().fetchOrders();

    print('📦 Tổng số đơn hàng từ API: ${allOrders.length}');

    for (var order in allOrders) {
      print('🧾 Đơn hàng: orderId=${order.orderId}, userId=${order.userId}, tên=${order.nameCustomer}');
    }

    // ⚠️ Lọc theo userId hiện tại
    final filteredOrders = allOrders.where((order) => order.userId == widget.userId).toList();

    print('✅ Sau khi lọc userId=${widget.userId}, còn lại: ${filteredOrders.length} đơn');

    setState(() {
      _orders = filteredOrders;
      _isLoading = false;
    });
  } catch (e) {
    print("❌ Lỗi lấy đơn hàng: $e");
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Không có đơn hàng nào'))
              : ListView.builder(
                  itemCount: _orders.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('Mã đơn: #${order.orderId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Khách hàng: ${order.nameCustomer}'),
                            Text('Tổng tiền: ${order.totalPrice.toStringAsFixed(0)}đ'),
                            Text('Trạng thái: ${order.status}'),
                            Text('Ngày: ${order.createdAt.toLocal()}'.split('.')[0]),
                          ],
                        ),
                        onTap: () {
                          // TODO: Chuyển sang trang chi tiết đơn hàng nếu muốn
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
