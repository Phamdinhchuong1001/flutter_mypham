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
  final Map<String, dynamic> user; // 👈 Thêm thuộc tính user

  const AdminDashboard({Key? key, required this.user}) : super(key: key); // 👈 Nhận từ constructor

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}


class _AdminDashboardState extends State<AdminDashboard> {
  // Dashboard Statistics
  int totalUsers = 0;
  int totalOrders = 0;
  double totalRevenue = 0;
  List<dynamic> topProducts = [];
  List<OrderProduct> recentOrders = [];

  // Main theme color and complementary palette
  final Color mainColor = Color(0xFF162F4A);     // Deep blue - primary
  final Color accentColor = Color(0xFF3A5F82);   // Medium blue - secondary
  final Color lightColor = Color(0xFF718EA4);    // Light blue - tertiary
  final Color ultraLightColor = Color(0xFFD0DCE7); // Very light blue - background

  // Service instances
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
    //  Gọi API và cập nhật UI
    final userCount = await _userService.getTotalUsersCount();
    setState(() {
      totalUsers = userCount;
    });

    //  Các đoạn sau giữ nguyên
    final orderAnalytics = await _orderService.getOrderAnalytics();
    setState(() {
      totalOrders = orderAnalytics['totalOrders'] ?? 0;
      totalRevenue = orderAnalytics['totalRevenue'] ?? 0.0;
    });

    final topProductsData = await _productService.getTopSellingProducts();
    final orderAnalyticsProductSales = orderAnalytics['productSales'] ?? {};
    setState(() {
      topProducts = topProductsData
          .map((product) => {
                ...product.toJson(),
                'salesCount': orderAnalyticsProductSales[product.id] ?? 0
              })
          .toList();
    });

    final recentOrdersData = await _orderService.getRecentOrders();
    setState(() {
      recentOrders = recentOrdersData.map((order) => order).toList();
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Sidebar Navigation
          if (MediaQuery.of(context).size.width > 600)
            _buildSidebar(),
          // Drawer for mobile
          if (MediaQuery.of(context).size.width <= 600)
            Drawer(
              child: _buildSidebar(),
            ),
          // Main Dashboard Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Cards
                    _buildQuickStatsRow(),

                    const SizedBox(height: 20),

                    // Charts and Detailed Stats
                    MediaQuery.of(context).size.width > 1000
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Products Chart
                        Expanded(
                          child: _buildTopProductsChart(),
                        ),
                        const SizedBox(width: 20),
                        // Recent Orders
                        Expanded(
                          child: _buildRecentOrdersList(),
                        ),
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
            ),
          ),
        ],
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
          icon: Icons.shopping_cart,
          color: accentColor,
        ),
        _buildStatCard(
          title: 'Tổng Doanh Thu',
          value: NumberFormat.currency(symbol: 'đ').format(totalRevenue),
          icon: Icons.monetization_on,
          color: lightColor,
        ),
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
                // _buildNavItem(Icons.dashboard_rounded, 'Bảng Điều Khiển', true, () {}),
                _buildNavItem(Icons.people_alt_rounded, 'Người Dùng', false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminUserScreen()));
                }),
                _buildNavItem(Icons.shopping_cart_rounded, 'Đơn Hàng', false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminOrderScreen()));
                }),
                _buildNavItem(Icons.spa_rounded, 'Sản Phẩm', false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminProductScreen()));
                }),
                _buildNavItem(Icons.location_on_rounded, 'Địa Chỉ', false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddressManagementScreen()));
                }),
                
                _buildNavItem(Icons.notifications_rounded, 'Thông Báo', false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserNotificationManager()));
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
            child: Icon(
              Icons.admin_panel_settings,
              color: mainColor,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
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
                Icon(
                  icon,
                  color: isActive ? Colors.white : mainColor,
                  size: 22,
                ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 1200
          ? (MediaQuery.of(context).size.width - 340) / 3 - 16
          : MediaQuery.of(context).size.width > 800
          ? (MediaQuery.of(context).size.width - 340) / 2 - 16
          : MediaQuery.of(context).size.width - 340 - 16,
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title == 'Tổng Doanh Thu'
                              ? Utils.formatCurrency(
                              double.parse(value.replaceAll(RegExp(r'[^\d.]'), '')))
                              : value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sản Phẩm Bán Chạy Nhất',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Icon(Icons.trending_up, color: mainColor),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: topProducts.map((product) {
                    final index = topProducts.indexOf(product);
                    // Create colors based on index
                    final colors = [
                      mainColor,        // Deep blue
                      accentColor,      // Medium blue
                      lightColor,       // Light blue
                      Color(0xFF4A6F8A), // Another blue variant
                    ];
                    final colorIndex = index % colors.length;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (product['salesCount'] ?? 0).toDouble(),
                          color: colors[colorIndex],
                          width: 22,
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: topProducts
                                .map((p) => (p['salesCount'] ?? 0).toDouble())
                                .reduce((a, b) => a > b ? a : b) * 1.1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
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
                                  index < topProducts.length
                                      ? topProducts[index]['productName']
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn Hàng Gần Đây',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('Xem tất cả'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminOrderScreen()));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: mainColor,
                  ),
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
                      Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
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
    final statusColors = {
      'pending': mainColor,           // Deep blue
      'processing': accentColor,      // Medium blue
      'completed': lightColor,        // Light blue
      'cancelled': Color(0xFF4A6F8A), // Another blue variant
    };
    final status = _orderService.getStatusText(order.status);
    final statusColor = statusColors[status] ?? Colors.grey;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ultraLightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.shopping_bag_outlined, color: mainColor),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn Hàng #${order.orderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Khách hàng: ${order.nameCustomer ?? 'Không có tên'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Utils.formatCurrency(order.totalPrice),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                      order.createdAt),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}