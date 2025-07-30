import 'package:flutter/material.dart';
import 'package:flutter_appmypham/services/api_service.dart';
import 'package:flutter_appmypham/services/user_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final String name, location, phone, email;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  int? userId;
  String avatar = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _locationController = TextEditingController(text: widget.location);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserStorage.getUserData();
    setState(() {
      userId = user?['id'];
      avatar = user?['avatar'] ?? '';
    });
  }

  void _saveUpdate() async {
    if (_formKey.currentState!.validate() && userId != null) {
      final message = await ApiService.updateUser(
        id: userId!,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _locationController.text,
        oldPassword: _oldPasswordController.text.isNotEmpty
            ? _oldPasswordController.text
            : null,
        newPassword: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null,
      );

      if (message != null && message.contains('thành công')) {
        final currentUser = await UserStorage.getUserData();
        await UserStorage.saveUserData({
          'id': userId!,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'avatar': currentUser?['avatar'] ?? '', // giữ lại avatar
        });

        Navigator.pop(context, {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Cập nhật thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetworkAvatar = avatar.startsWith('http') || avatar.startsWith('/uploads');
final imageProvider = isNetworkAvatar
    ? NetworkImage(
        avatar.startsWith('/')
            ? 'http://172.20.10.5:3000$avatar' // ✅ Đổi IP ở đây
            : avatar,
      )
    : const AssetImage("assets/images/profile.jpg");


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Chỉnh sửa thông tin"),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatar.isNotEmpty ? imageProvider as ImageProvider : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 20),

              _buildInputField("Họ tên", _nameController),
              _buildInputField("Email", _emailController),
              _buildInputField("Số điện thoại", _phoneController),
              _buildInputField("Địa chỉ", _locationController),
              const SizedBox(height: 20),

              _buildPasswordField("Mật khẩu cũ (nếu đổi)", _oldPasswordController),
              _buildPasswordField("Mật khẩu mới", _newPasswordController),
              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 111, 36),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: _saveUpdate,
                  child: const Text("Lưu thay đổi"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Vui lòng nhập $label" : null,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
