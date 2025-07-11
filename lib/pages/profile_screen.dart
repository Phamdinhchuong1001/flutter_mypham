import 'package:flutter/material.dart';
import 'package:flutter_appmypham/services/user_storage.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String location = "VIET NAM";
  String phone = "Chưa có số điện thoại";
  String email = "";
  String avatar = ""; // ✅ avatar

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await UserStorage.getUserData();
    if (user != null) {
      setState(() {
        name = user['name'] ?? 'Chưa có tên';
        email = user['email'] ?? 'Chưa có email';
        phone = user['phone'] ?? 'Chưa có số điện thoại';
        location = user['location'] ?? 'VIET NAM';
        avatar = user['avatar'] ?? '';
      });
    } else {
      setState(() {
        name = 'Chưa có tên';
        email = 'Chưa có email';
        phone = 'Chưa có số điện thoại';
        location = 'VIET NAM';
        avatar = '';
      });
    }
  }

  void updateProfile(String newName, String newLocation, String newPhone, String newEmail) async {
    setState(() {
      name = newName;
      location = newLocation;
      phone = newPhone;
      email = newEmail;
    });

    await UserStorage.saveUserData({
      'id': 0, // Nếu cần lấy ID thực tế thì load từ SharedPreferences
      'name': newName,
      'email': newEmail,
      'phone': newPhone,
      'location': newLocation,
      'avatar': avatar, // ✅ lưu avatar cũ để không mất
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Thông tin cá nhân"),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ProfilePic(imageUrl: avatar),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 32),
            Info(infoKey: "Tên", info: name),
            Info(infoKey: "Địa chỉ", info: location),
            Info(infoKey: "Số điện thoại", info: phone),
            Info(infoKey: "Email", info: email),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 111, 36),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          name: name,
                          location: location,
                          phone: phone,
                          email: email,
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, String>) {
                      updateProfile(
                        result['name']!,
                        result['location']!,
                        result['phone']!,
                        result['email']!,
                      );
                    }
                  },
                  child: const Text("Chỉnh sửa"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    required this.imageUrl,
    this.isShowPhotoUpload = false,
    this.imageUploadBtnPress,
  });

  final String imageUrl;
  final bool isShowPhotoUpload;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl.startsWith('http') || imageUrl.startsWith('/uploads');
    final imageWidget = isNetworkImage
        ? NetworkImage(imageUrl.startsWith('/') ? 'http://127.0.0.1:3000$imageUrl' : imageUrl)
        : AssetImage('assets/images/profile.jpg') as ImageProvider;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: imageWidget,
          ),
          if (isShowPhotoUpload)
            InkWell(
              onTap: imageUploadBtnPress,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            )
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({super.key, required this.infoKey, required this.info});

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoKey,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              info,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
