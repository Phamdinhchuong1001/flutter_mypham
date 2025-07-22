import 'package:flutter/material.dart';
import 'package:flutter_appmypham/models/user_info.dart';
import 'package:flutter_appmypham/services/admin_account_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final bool isNewUser;

  const EditUserScreen({super.key, required this.userId, required this.isNewUser});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminAccountService();

  String name = '';
  String email = '';
  String phone = '';
  String location = '';
  String password = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewUser) {
      _loadUser();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadUser() async {
    final user = await _adminService.getUserAccount(widget.userId);
    if (user != null) {
      setState(() {
        name = user.name;
        email = user.email;
        phone = user.phone;
        location = user.location;
        password = ''; // Không hiển thị mật khẩu cũ
        isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = UserInfo(
      id: int.parse(widget.userId),
      name: name,
      email: email,
      phone: phone,
      location: location,
      password: password,
    );

    final result = await _adminService.updateUser(updatedUser);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật người dùng thành công')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại')),
      );
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F6FC), // nền giống admin
    appBar: AppBar(
      title: const Text('Chỉnh sửa người dùng'),
      backgroundColor: const Color(0xFF1E293B), // màu navy đậm
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      elevation: 0,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin người dùng',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: 'Tên',
                            icon: Icons.person,
                            initialValue: name,
                            validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null,
                            onChanged: (val) => name = val,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Email',
                            icon: Icons.email,
                            initialValue: email,
                            validator: (val) => val!.isEmpty ? 'Vui lòng nhập email' : null,
                            onChanged: (val) => email = val,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Số điện thoại',
                            icon: Icons.phone,
                            initialValue: phone,
                            onChanged: (val) => phone = val,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Địa chỉ',
                            icon: Icons.location_on,
                            initialValue: location,
                            onChanged: (val) => location = val,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Mật khẩu mới (nếu muốn đổi)',
                            icon: Icons.lock,
                            onChanged: (val) => password = val,
                            obscureText: true,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Lưu thay đổi'),
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E40AF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
  );
}

Widget _buildTextField({
  required String label,
  required IconData icon,
  String? initialValue,
  String? Function(String?)? validator,
  required void Function(String) onChanged,
  bool obscureText = false,
}) {
  return TextFormField(
    initialValue: initialValue,
    validator: validator,
    onChanged: onChanged,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

}
