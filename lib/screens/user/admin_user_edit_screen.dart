import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appmypham/models/user_info.dart';
import 'package:flutter_appmypham/services/admin_account_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EditUserScreen extends StatefulWidget {
  final bool isNewUser;
  final String? userId;

  const EditUserScreen({
    super.key,
    required this.isNewUser,
    this.userId,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final AdminAccountService _adminAccountService = AdminAccountService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Màu sắc UI
  final Color mainColor = const Color(0xFF162F4A);
  final Color accentColor = const Color(0xFF3A5F82);
  final Color lightColor = const Color(0xFF718EA4);
  final Color ultraLightColor = const Color(0xFFD0DCE7);

  UserInfo? _userInfo;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (!widget.isNewUser && widget.userId != null) {
        _userInfo = await _adminAccountService.getUserAccount(widget.userId!);
        _nameController.text = _userInfo?.name ?? '';
        _phoneController.text = _userInfo?.phone ?? '';
      }
    } catch (e) {
      _showErrorSnackBar('Không thể tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (widget.isNewUser) {
      final newUser = UserInfo(
        id: 0, // Có thể để 0 nếu backend tự sinh ID
        name: name,
        phone: phone,
        email: '', // Cập nhật nếu bạn có dữ liệu
        location: '', // Cập nhật nếu bạn có dữ liệu
        avatar: null,
      );

      final result = await _adminAccountService.createUser(newUser);
      if (result) {
        _showSuccessSnackBar('Đã tạo người dùng mới thành công');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Không thể tạo người dùng');
      }
    } else if (_userInfo != null) {
      final updatedUser = UserInfo(
        id: _userInfo!.id,
        name: name,
        phone: phone,
        email: _userInfo!.email,
        location: _userInfo!.location,
        avatar: _userInfo!.avatar,
      );

      final result = await _adminAccountService.updateUser(updatedUser);
      if (result) {
        _showSuccessSnackBar('Đã cập nhật người dùng thành công');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Không thể cập nhật người dùng');
      }
    }
  } catch (e) {
    _showErrorSnackBar('Lỗi khi lưu người dùng: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ultraLightColor.withOpacity(0.3),
      appBar: AppBar(
        title: Text(
          widget.isNewUser ? 'Thêm Người Dùng Mới' : 'Chỉnh Sửa Người Dùng',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!widget.isNewUser)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUserInfoForm(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  widget.isNewUser ? 'Tạo Người Dùng' : 'Lưu Thay Đổi',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildUserInfoForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: mainColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông Tin Cá Nhân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên người dùng',
                prefixIcon: Icon(Icons.person, color: accentColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone, color: accentColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                final phoneRegex = RegExp(r'^(0|\+84)(\d{9,10})$');
                if (!phoneRegex.hasMatch(value)) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            if (!widget.isNewUser && _userInfo != null) ...[
              const SizedBox(height: 20),
              Text(
                'Cập nhật lần cuối: Không rõ thời gian',
                style: TextStyle(color: accentColor),
              ),
              Text('ID: ${_userInfo!.id}', style: TextStyle(color: accentColor)),
            ],
          ],
        ),
      ),
    );
  }
}
