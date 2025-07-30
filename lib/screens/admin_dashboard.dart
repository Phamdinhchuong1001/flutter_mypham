import 'package:flutter_appmypham/auth/login_or_register.dart';
import 'package:flutter_appmypham/models/order.dart';
import 'package:flutter_appmypham/screens/address/admin_address_screen.dart';
import 'package:flutter_appmypham/screens/order/admin_order_screen.dart';
import 'package:flutter_appmypham/screens/product/admin_product_screen.dart';
import 'package:flutter_appmypham/screens/user/admin_user_screen.dart';
import 'package:flutter_appmypham/services/admin_account_service.dart';
import 'package:flutter_appmypham/services/admin_order_service.dart';
import 'package:flutter_appmypham/services/admin_product_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/admin_auth_service.dart';
import '../utils/utils.dart';
import 'notification/admin_notification_screen.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalProducts = 0;
  int totalUsers = 0;
  int totalOrders = 0;
  double totalRevenue = 0;
  List<dynamic> topProducts = [];
  List<OrderProduct> recentOrders = [];

  final Color mainColor = Color(0xFF162F4A);
  final Color accentColor = Color(0xFF3A5F82);
  final Color lightColor = Color(0xFF718EA4);
  final Color ultraLightColor = Color(0xFFD0DCE7);

  final _userService = AdminAccountService();
  final _orderService = AdminOrderService();
  final _productService = AdminProductService();
  final _authService = AdminAuthService();

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final userCount = await _userService.getTotalUsersCount();
      final productCount = await _productService.getTotalProductsCount();
      final fetchedTotalOrders = await _orderService.getTotalOrders();        
      final fetchedTotalRevenue = await _orderService.getTotalRevenue();     
      final recentOrdersData = await _orderService.getRecentOrders();

      setState(() {
        totalUsers = userCount;
        totalProducts = productCount;
        totalOrders = fetchedTotalOrders;
        totalRevenue = fetchedTotalRevenue;
        recentOrders = recentOrdersData;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu bảng điều khiển: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải dữ liệu: $e')),
      );
    }
  }

  void _handleLogout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginOrRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: isLargeScreen ? null : Drawer(child: _buildSidebar()),
      body: isLargeScreen
          ? Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            )
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStatsRow(),
            const SizedBox(height: 20),
            MediaQuery.of(context).size.width > 1000
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTopProductsChart()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildRecentOrdersList()),
                    ],
                  )
                : Column(
                    children: [
                      _buildTopProductsChart(),
                      const SizedBox(height: 20),
                      _buildRecentOrdersList(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: mainColor,
      title: Row(
        children: [
          Icon(Icons.spa, size: 28, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'COCOON',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
      elevation: 4,
      shadowColor: Colors.black26,
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: Colors.white),
          tooltip: 'Đăng xuất',
          onPressed: _handleLogout,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          _buildUserHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildNavItem(Icons.people_alt_rounded, 'Người Dùng', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminUserScreen()));
                }),
                _buildNavItem(Icons.shopping_cart_rounded, 'Đơn Hàng', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderScreen()));
                }),
                _buildNavItem(Icons.spa_rounded, 'Sản Phẩm', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProductScreen()));
                }),
                _buildNavItem(Icons.location_on_rounded, 'Địa Chỉ', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddressManagementScreen()));
                }),
                _buildNavItem(Icons.notifications_rounded, 'Thông Báo', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => UserNotificationManager()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final name = widget.user['name'] ?? 'Chưa rõ tên';
    final email = widget.user['email'] ?? 'Không rõ email';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: mainColor,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Icon(Icons.admin_panel_settings, color: mainColor, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? mainColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: isActive ? Colors.white10 : ultraLightColor,
          splashColor: isActive ? Colors.white24 : lightColor.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.white : mainColor, size: 22),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : mainColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _buildStatCard(
          title: 'Tổng Người Dùng',
          value: totalUsers.toString(),
          icon: Icons.people,
          color: mainColor,
        ),
        _buildStatCard(
          title: 'Tổng Đơn Hàng',
          value: totalOrders.toString(),
          icon: Icons.shopping_bag,
          color: accentColor,
        ),
        _buildStatCard(
          title: 'Tổng Sản Phẩm',
          value: totalProducts.toString(),
          icon: Icons.shopping_cart,
          color: lightColor,
        ),
        _buildStatCard(
          title: 'Tổng Doanh Thu',
          value: totalRevenue.toString(),
          icon: Icons.monetization_on,
          color: Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
                SizedBox(width: 16),
             Expanded(
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
    SizedBox(height: 8),
    FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        title == 'Tổng Doanh Thu'
            ? Utils.formatCurrency(
                double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0)
            : value,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  ],
),

)

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductsChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sản Phẩm Bán Chạy Nhất', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
                Icon(Icons.trending_up, color: mainColor),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: topProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final colors = [mainColor, accentColor, lightColor, Color(0xFF4A6F8A)];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (product['salesCount'] ?? 0).toDouble(),
                          color: colors[index % colors.length],
                          width: 22,
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: topProducts.map((p) => (p['salesCount'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) * 1.1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: 5),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.3,
                              child: SizedBox(
                                width: 60,
                                child: Text(
                                  index < topProducts.length ? topProducts[index]['productName'] : '',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: mainColor),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final product = topProducts[group.x];
                        return BarTooltipItem(
                          '${product['productName']}\n',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Đã bán: ${product['salesCount']}',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đơn Hàng Gần Đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
                TextButton.icon(
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('Xem tất cả'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminOrderScreen()));
                  },
                  style: TextButton.styleFrom(foregroundColor: mainColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentOrders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('Chưa có đơn hàng nào', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              ...recentOrders.map((order) => _buildOrderCard(order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderProduct order) {
  final status = _orderService.getStatusText(order.status);
  final statusColor = {
    'Chờ xử lý': Colors.orange,
    'Đã xác nhận': Colors.blue,
    'Đang giao': Colors.indigo,
    'Đã giao': Colors.green,
    'Đã huỷ': Colors.red,
    'Không xác định': Colors.grey,
  }[status] ?? Colors.grey;

  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng #${order.orderId}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khách hàng: ${order.nameCustomer ?? 'Không có tên'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(order.createdAt),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Utils.formatCurrency(order.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
