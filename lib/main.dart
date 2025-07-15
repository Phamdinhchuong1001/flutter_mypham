// Nhập các gói thư viện cần thiết từ Flutter và các package bên ngoài
import 'package:flutter/material.dart'; // Thư viện giao diện Flutter
import 'package:provider/provider.dart'; // Thư viện quản lý trạng thái Provider
import 'package:flutter_appmypham/auth/login_or_register.dart'; // Import màn hình LoginOrRegister
import 'package:flutter_appmypham/themes/theme_provider.dart'; // Import class ThemeProvider để xử lý giao diện tối/sáng

// Hàm main là điểm khởi đầu của ứng dụng
void main() {
  runApp(
    // Sử dụng Provider để cung cấp đối tượng ThemeProvider cho toàn bộ ứng dụng
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Khởi tạo ThemeProvider
      child: const MyApp(), // Truyền MyApp là widget gốc của ứng dụng
    ),
  );
}

// Widget gốc của ứng dụng, kế thừa từ StatelessWidget vì không cần quản lý trạng thái nội bộ
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor với key được truyền vào (dùng để xác định widget trong cây widget)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner "debug" ở góc phải trên màn hình
      home: const LoginOrRegister(), // Màn hình đầu tiên khi mở app (login hoặc đăng ký)
      
      // Lấy theme hiện tại từ ThemeProvider để áp dụng cho toàn ứng dụng
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
