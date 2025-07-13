import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String baseUrl = 'http://localhost:3000/api/admin';

  static String? token;
  static String? currentUsername;

  /// Đăng nhập admin
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        token = data['token'];
        currentUsername = username;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_token', token!);
        await prefs.setString('admin_username', username);

        return null; // Đăng nhập thành công
      } else {
        return data['message'] ?? 'Đăng nhập thất bại';
      }
    } catch (e) {
      return 'Lỗi đăng nhập: $e';
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    token = null;
    currentUsername = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_username');
  }

  /// Đổi mật khẩu
  Future<String?> changePassword(String username, String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');

      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return null; // Đổi mật khẩu thành công
      } else {
        return data['message'] ?? 'Đổi mật khẩu thất bại';
      }
    } catch (e) {
      return 'Lỗi đổi mật khẩu: $e';
    }
  }

  /// Kiểm tra trạng thái đã đăng nhập hay chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('admin_token');
    currentUsername = prefs.getString('admin_username');
    return token != null;
  }
  /// Lấy tên đăng nhập hiện tại
Future<String?> get currentUser async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('admin_username');
}
}
