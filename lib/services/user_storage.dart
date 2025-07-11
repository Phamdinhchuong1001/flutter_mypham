import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  /// Lưu dữ liệu người dùng vào SharedPreferences
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user['id'] ?? 0);
    await prefs.setString('user_name', user['name'] ?? '');
    await prefs.setString('user_email', user['email'] ?? '');
    await prefs.setString('user_phone', user['phone'] ?? '');
    await prefs.setString('user_location', user['location'] ?? '');
    await prefs.setString('user_avatar', user['avatar'] ?? '');
  }

  /// Lấy dữ liệu người dùng từ SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email == null || email.isEmpty) return null;

    return {
      'id': prefs.getInt('user_id') ?? 0,
      'name': prefs.getString('user_name') ?? '',
      'email': email,
      'phone': prefs.getString('user_phone') ?? '',
      'location': prefs.getString('user_location') ?? '',
      'avatar': prefs.getString('user_avatar') ?? '',
    };
  }

  /// Cập nhật avatar riêng biệt
  static Future<void> updateAvatar(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarUrl);
  }

  /// Xoá toàn bộ dữ liệu người dùng
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
