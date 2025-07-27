import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../models/user_info.dart';
import '../../models/cart_item.dart' as cart_item;
import '../../services/admin_order_service.dart';
import '../../services/admin_account_service.dart';
import '../../utils/utils.dart';

final Color mainColor = Color(0xFF162F4A);
final Color accentColor = Color(0xFF3A5F82);
final Color lightColor = Color(0xFF718EA4);
final Color ultraLightColor = Color(0xFFD0DCE7);

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final _adminOrderService = AdminOrderService();
  final _adminAccountService = AdminAccountService();

  final List<String> statuses = ['pending', 'delivering', 'preparing', 'completed', 'cancelled'];
  String _filterStatus = "all";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ultraLightColor.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        title: Text('Quản lý đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ultraLightColor,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đơn hàng...',
                  prefixIcon: Icon(Icons.search, color: accentColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 16),
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ultraLightColor,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterStatus,
                icon: Icon(Icons.arrow_drop_down, color: accentColor),
                style: TextStyle(color: mainColor),
                items: ["all", ...statuses].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_adminOrderService.getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<List<OrderProduct>>(
      future: _adminOrderService.getOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: accentColor));
        }

        List<OrderProduct> orders = snapshot.data!;

        if (_filterStatus != "all") {
          orders = orders.where((order) => order.status == _filterStatus).toList();
        }

        if (_searchQuery.isNotEmpty) {
          orders = orders
              .where((order) => order.orderId.toString().toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 70, color: lightColor),
                SizedBox(height: 16),
                Text('Không tìm thấy đơn hàng nào', style: TextStyle(color: accentColor)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            return FutureBuilder<UserInfo?>(
              future: _adminAccountService.getUserAccount(order.userId.toString()),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator(color: accentColor)),
                  );
                }

                final user = userSnapshot.data!;
                return _buildOrderCard(order, user, context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderProduct order, UserInfo user, BuildContext context) {
    final Map<String, Color> statusColors = {
      'completed': Colors.teal.shade700,
      'cancelled': Colors.deepOrange.shade700,
      'preparing': Colors.amber.shade700,
      'delivering': Colors.blueAccent.shade700,
      'pending': Colors.purple.shade700,
    };

    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt);
    Color statusColor = statusColors[order.status] ?? Colors.grey.shade700;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          collapsedBackgroundColor: Colors.white,
          backgroundColor: ultraLightColor.withOpacity(0.2),
          iconColor: accentColor,
          collapsedIconColor: accentColor,
          title: _buildOrderHeader(order, formattedDate, statusColor),
          children: [
            Divider(height: 1, color: lightColor.withOpacity(0.3)),
            _buildOrderDetails(order, user),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderProduct order, String date, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            _adminOrderService.getStatusText(order.status),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đơn hàng #${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainColor)),
              SizedBox(height: 4),
              Text(date, style: TextStyle(color: lightColor, fontSize: 12)),
            ],
          ),
        ),
        Text(Utils.formatCurrency(order.totalPrice), style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
      ],
    );
  }

  Widget _buildOrderDetails(OrderProduct order, UserInfo user) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Thông tin khách hàng', CupertinoIcons.person, [
            _infoRow('Tên', user.name),
            _infoRow('SĐT', user.phone),
            _infoRow('Địa chỉ', order.address ?? 'Khách tự đến lấy'),
          ]),
          SizedBox(height: 20),
          _buildSection('Chi tiết đơn hàng', CupertinoIcons.doc_text, [
            _infoRow('Thanh toán', order.payment ?? 'Không xác định'),
            _infoRow('Phí giao hàng', Utils.formatCurrency(order.deliveryFee)),
            _infoRow('Chiết khấu', order.orderDiscount != null ? Utils.formatCurrency(order.orderDiscount!) : 'Không'),
            _infoRow('Ghi chú', order.note ?? 'Không có ghi chú'),
          ]),
          SizedBox(height: 20),
          _buildSection('Sản phẩm', CupertinoIcons.cart, [
            Column(
              children: order.listCartItem.map((item) => _buildOrderItem(item)).toList(),
            )
          ]),
          SizedBox(height: 20),
          _buildStatusUpdate(order),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 20, color: accentColor), SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: mainColor))]),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: ultraLightColor)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: TextStyle(color: lightColor, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(color: mainColor, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildOrderItem(cart_item.CartItemModel item) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(item.title, style: TextStyle(color: mainColor)),
      Text('${item.quantity} x ${Utils.formatCurrency(item.price)}', style: TextStyle(color: accentColor)),
    ],
  );
}

  Widget _buildStatusUpdate(OrderProduct order) {
    final Map<String, Color> statusColors = {
      'completed': Colors.teal.shade700,
      'cancelled': Colors.red.shade700,
      'preparing': Colors.amber.shade700,
      'delivering': Colors.blueAccent.shade700,
      'pending': Colors.purple.shade700,
    };
    final color = statusColors[order.status] ?? Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Cập nhật trạng thái', CupertinoIcons.refresh),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(children: [
                Icon(CupertinoIcons.info_circle, color: color),
                SizedBox(width: 8),
                Text('Trạng thái hiện tại: ${_adminOrderService.getStatusText(order.status)}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ]),
              SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: order.status,
                    onChanged: (status) {
                      if (status != null) {
                        _adminOrderService.updateOrderStatus(order.orderId.toString(), status).then((_) => setState(() {}));
                      }
                    },
                    decoration: InputDecoration(labelText: 'Cập nhật trạng thái', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: statuses.map((s) {
                      return DropdownMenuItem(value: s, child: Text(_adminOrderService.getStatusText(s)));
                    }).toList(),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _showCancelOrderDialog(order),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Hủy đơn', style: TextStyle(color: Colors.white)),
                )
              ])
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: accentColor),
        SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: mainColor)),
      ]),
    );
  }

  void _showCancelOrderDialog(OrderProduct order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận hủy đơn', style: TextStyle(fontWeight: FontWeight.bold, color: mainColor)),
        content: Text('Bạn chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Quay lại')),
          ElevatedButton(
            onPressed: () {
              _adminOrderService.updateOrderStatus(order.orderId.toString(), "cancelled").then((_) => setState(() {}));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
