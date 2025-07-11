import 'dart:convert';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  /// Đăng ký tài khoản
  static Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) return null;

      final data = jsonDecode(response.body);
      return data['message'] ?? 'Lỗi không xác định';
    } catch (_) {
      return 'Không thể kết nối tới máy chủ';
    }
  }

  /// Đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': {
            'id': data['user']['id'],
            'name': data['user']['name'],
            'email': data['user']['email'],
            'phone': data['user']['phone'] ?? '',
            'location': data['user']['location'] ?? '',
            'avatar': data['user']['avatar'] ?? '',
          }
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (_) {
      return {
        'success': false,
        'message': 'Không thể kết nối tới máy chủ',
      };
    }
  }

  /// Cập nhật thông tin người dùng
  static Future<String?> updateUser({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'phone': phone,
        'location': address,
      };

      if (oldPassword != null && oldPassword.isNotEmpty &&
          newPassword != null && newPassword.isNotEmpty) {
        body['oldPassword'] = oldPassword;
        body['newPassword'] = newPassword;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 200
          ? data['message']
          : data['message'] ?? 'Có lỗi xảy ra';
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }

  /// Upload ảnh đại diện - Mobile
  static Future<String?> uploadAvatar(int userId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/$userId/avatar'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);
        return data['avatar']; // Trả về đường dẫn avatar
      }
    } catch (_) {}
    return null;
  }

  /// Upload ảnh đại diện - Web
  static Future<String?> uploadAvatarWeb(int userId) async {
    try {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      await input.onChange.first;

      if (input.files == null || input.files!.isEmpty) return null;

      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = reader.result as List<int>;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/$userId/avatar'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);
        return data['avatar'];
      }
    } catch (_) {}
    return null;
  }

  /// Tự động chọn đúng phương thức upload
  static Future<String?> uploadAvatarAuto(int userId, dynamic file) async {
    if (kIsWeb) {
      return await uploadAvatarWeb(userId);
    } else if (file is File) {
      return await uploadAvatar(userId, file);
    }
    return null;
  }
}
