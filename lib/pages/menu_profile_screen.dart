import 'package:flutter/material.dart';
import 'package:flutter_appmypham/pages/login_page.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'favorite_screen.dart';
// ignore: duplicate_import
import 'login_page.dart'; 
// ✅ Nhớ import màn hình bạn muốn chuyển tới

class MenuProfileScreen extends StatelessWidget {
  const MenuProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔶 AppBar đơn giản với màu trắng và chữ đen
      appBar: AppBar(
        backgroundColor: Colors.orange, // ✅ nền AppBar trắng
        foregroundColor: Colors.white, // ✅ màu chữ đen
        title: const Text("Cài Đặt"),
        leading: const BackButton(),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),

            // 🔶 "My Account" có xử lý chuyển trang
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
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      name: "Nguyễn Văn A",
                      email: "nguyenvana@example.com",
                      phone: "0123456789",
                      location: "Hồ Chí Minh",
                    ),
                  ),
                );
              },
            ),

            CustomProfileMenu(
              text: "Help Center",
              iconData: Icons.help_outline,
              press: () {}, // ✅ Bổ sung để tránh thiếu press
            ),

            CustomProfileMenu(
              text: "Đăng xuất",
              iconData: Icons.logout,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage(
                     onTap: () {},
                  )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 🔵 Widget hiển thị ảnh đại diện tròn với nút đổi ảnh
class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white), // Icon nếu không có ảnh
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
                  backgroundColor: Color(0xFFF5F6F9),
                ),
                onPressed: () {
                  // 🔸 Bạn có thể thêm xử lý đổi ảnh tại đây
                },
                child: const Icon(Icons.camera_alt, color: Color(0xFF757575), size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 🔵 Widget hiển thị 1 dòng menu trong danh sách
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
        onPressed: press ?? () {}, // nếu không có xử lý thì mặc định là không làm gì
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
