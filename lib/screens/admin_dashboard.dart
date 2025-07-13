import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_appmypham/services/admin_account_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  final AdminAccountService _userService = AdminAccountService();

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final count = await _userService.getTotalUsersCount();
    setState(() {
      totalUsers = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.people, color: Colors.blue, size: 36),
                title: Text('Tổng Người Dùng'),
                subtitle: Text('$totalUsers'),
              ),
            ),
            const SizedBox(height: 20),
            // Bạn có thể thêm các Widget tạm hiển thị thông báo "Đang phát triển..."
            Card(
              color: Colors.yellow[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Biểu đồ sản phẩm và đơn hàng sẽ được hiển thị khi các service tương ứng sẵn sàng.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
