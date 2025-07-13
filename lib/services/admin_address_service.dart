import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';

class AddressService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Lấy danh sách địa chỉ
  Future<List<Address>> getAddresses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/addresses'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Address.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi getAddresses: $e');
    }
    return [];
  }

  // Thêm địa chỉ mới
  Future<bool> addAddress(Address address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(address.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi addAddress: $e');
      return false;
    }
  }

  // Cập nhật địa chỉ
  Future<bool> updateAddress(Address address) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/${address.addressId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(address.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi updateAddress: $e');
      return false;
    }
  }

  // Xóa địa chỉ
  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi deleteAddress: $e');
      return false;
    }
  }
}
