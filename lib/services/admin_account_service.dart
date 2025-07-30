import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appmypham/models/user_info.dart';

class AdminAccountService {
  static const String baseUrl = 'http://172.20.10.5:3000/api'; 

  Future<List<UserInfo>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((json) => UserInfo.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getAllUsers: $e');
    }
    return [];
  }

  Future<UserInfo?> getUserAccount(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        return UserInfo.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error getUserAccount: $e');
    }
    return null;
  }

  Future<bool> createUser(UserInfo userInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userInfo.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error createUser: $e');
      return false;
    }
  }

  Future<bool> updateUser(UserInfo userInfo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${userInfo.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userInfo.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updateUser: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleteUser: $e');
      return false;
    }
  }

 Future<int> getTotalUsersCount() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/admin/users/count')); // ❗Không thêm /api nữa
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalUsers'] ?? 0;
    }
  } catch (e) {
    print('Error getTotalUsersCount: $e');
  }
  return 0;
}

}
