import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_appmypham/pages/order_list_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_appmypham/pages/login_page.dart';
import 'package:flutter_appmypham/pages/profile_screen.dart';
import 'package:flutter_appmypham/pages/edit_profile_screen.dart';
import 'package:flutter_appmypham/pages/favorite_screen.dart';
import 'package:flutter_appmypham/services/api_service.dart';
import 'package:flutter_appmypham/services/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuProfileScreen extends StatefulWidget {
  const MenuProfileScreen({super.key});

  @override
  State<MenuProfileScreen> createState() => _MenuProfileScreenState();
}

class _MenuProfileScreenState extends State<MenuProfileScreen> {
  String avatar = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = await UserStorage.getUserData();
    if (user != null) {
      setState(() {
        avatar = user['avatar'] ?? '';
        userId = user['id'] ?? 0;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = await UserStorage.getUserData();
    if (user == null || user['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập lại")),
      );
      return;
    }

    final int id = user['id'];
    dynamic file;

    if (!kIsWeb) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      file = File(picked.path);
    }

    final uploadedPath = await ApiService.uploadAvatarAuto(id, file);
    if (uploadedPath != null) {
      await UserStorage.saveUserData({
        'id': id,
        'name': user['name'] ?? '',
        'email': user['email'] ?? '',
        'phone': user['phone'] ?? '',
        'location': user['location'] ?? '',
        'avatar': uploadedPath,
      });

      setState(() {
        avatar = uploadedPath;
        userId = id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật ảnh đại diện thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi upload ảnh đại diện")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Cài Đặt"),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfilePic(imageUrl: avatar, onUpload: _pickAndUploadImage),
            const SizedBox(height: 20),

            CustomProfileMenu(
              text: "Thông tin cá nhân",
              iconData: Icons.person,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),

            CustomProfileMenu(
              text: "Sản phẩm yêu thích",
              iconData: Icons.favorite,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteProductsScreen()),
                );
              },
            ),

            CustomProfileMenu(
              text: "Cài đặt",
              iconData: Icons.settings,
              press: () async {
                final user = await UserStorage.getUserData();
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        name: user['name'] ?? '',
                        email: user['email'] ?? '',
                        phone: user['phone'] ?? '',
                        location: user['location'] ?? '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
                  );
                }
              },
            ),

            CustomProfileMenu(
              text: "Danh sách đơn hàng",
              iconData: Icons.list_alt,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderListScreen(userId: userId),
                  ),
                );
              },
            ),

            CustomProfileMenu(
              text: "Đăng xuất",
              iconData: Icons.logout,
              press: () {
                UserStorage.clearUserData();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onUpload;

  const ProfilePic({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl.startsWith('http') || imageUrl.startsWith('/uploads');
    final imageWidget = isNetworkImage
        ? NetworkImage(imageUrl.startsWith('/') ? 'http://172.20.10.5:3000$imageUrl' : imageUrl)
        : const AssetImage('assets/images/profile.jpg') as ImageProvider;

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: imageUrl.isNotEmpty ? imageWidget : null,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Positioned(
            right: -10,
            bottom: 0,
            child: SizedBox(
              height: 40,
              width: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: onUpload,
                child: const Icon(Icons.camera_alt, color: Color(0xFF757575), size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomProfileMenu extends StatelessWidget {
  const CustomProfileMenu({
    super.key,
    required this.text,
    required this.iconData,
    this.press,
  });

  final String text;
  final IconData iconData;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press ?? () {},
        child: Row(
          children: [
            Icon(iconData, color: const Color(0xFFFF7643), size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575), size: 16),
          ],
        ),
      ),
    );
  }
}
