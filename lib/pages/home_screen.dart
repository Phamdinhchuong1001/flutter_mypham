import 'package:flutter/material.dart';
import 'package:flutter_appmypham/pages/user_notification_screen.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/videococoon.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    final count = await ApiService.getUnreadNotificationCount(widget.userId);
    setState(() => unreadCount = count);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCategoryCard(String image, String label, String brands) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text(brands,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget buildPopularProductCard(String imgPath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildIngredientCard(
      String title, String desc, String imagePath, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 20)],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Expanded(
            flex: 3,
            child: Text(
              desc,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔍 Thanh tìm kiếm + chuông thông báo
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 🔔 Nút thông báo
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserNotificationScreen(userId: widget.userId),
                            ),
                          );
                          fetchUnreadCount(); // Load lại khi trở về
                        },
                        icon: const Icon(Icons.notifications_none),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 📽 Video nền
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),

            const SizedBox(height: 24),

            // Special for you
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Special for you",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  buildCategoryCard("assets/images/taytebaochet.jpg", "Skincare", "18 Brands"),
                  buildCategoryCard("assets/images/kemthoatay.jpg", "Fashion", "24 Brands"),
                  buildCategoryCard("assets/images/duongtoc.jpg", "Fashion", "24 Brands"),
                  buildCategoryCard("assets/images/gelruamat.jpg", "Fashion", "24 Brands"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Popular Product
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Popular Product",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("See More",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildPopularProductCard("assets/images/taytebaochet.jpg"),
                  buildPopularProductCard("assets/images/kemthoatay.jpg"),
                  buildPopularProductCard("assets/images/duongtoc.jpg"),
                  buildPopularProductCard("assets/images/gelruamat.jpg"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sản phẩm An Lành
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 1),
              child: Text(
                "Sản phẩm An Lành",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: [
                  buildIngredientCard("Lá bạc hà", "Dùng trong các sản phẩm như dầu gội, lá tắm trẻ em", "assets/images/orgin1.png", const Color(0xFF66883f)),
                  buildIngredientCard("Tinh dầu cam", "Làm thơm, thư giãn: sáp thơm, tinh dầu thơm", "assets/images/orgin2.png", const Color(0xFFc57200)),
                  buildIngredientCard("Dầu quả bơ", "Chiết xuất từ quả bơ bằng ép lạnh, giữ dưỡng chất tự nhiên.", "assets/images/orgin3.png", const Color(0xFF66883f)),
                  buildIngredientCard("Dầu dừa", "Chiết xuất từ cùi trắng quả dừa, dùng trong mỹ phẩm.", "assets/images/orgin4.png", const Color(0xFFb69a71)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
