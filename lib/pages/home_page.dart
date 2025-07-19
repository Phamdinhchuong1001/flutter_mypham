import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_appmypham/auth/login_or_register.dart';
import 'package:flutter_appmypham/pages/cart_screen.dart';
import 'package:flutter_appmypham/pages/home_screen.dart';
import 'package:flutter_appmypham/pages/menu_profile_screen.dart';
import 'package:flutter_appmypham/pages/products_screen.dart';

class HomePage extends StatefulWidget {
  final int userId; // ✅ Thêm userId
  const HomePage({super.key, required this.userId}); // ✅ Bắt buộc truyền userId

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(userId: widget.userId),     // ✅ Truyền userId vào HomeScreen
      ProductsScreen(),
      CartScreen(),
      MenuProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 3,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Colors.pink.shade100.withOpacity(0.2),
        surfaceTintColor: Colors.white,
        selectedIndex: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(
    icon: Icon(Icons.house_outlined, color: Colors.grey),
    selectedIcon: Icon(Icons.house_rounded, color: Color.fromARGB(255, 74, 238, 101)),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.shopping_bag, color: Colors.grey),
    selectedIcon: Icon(Icons.shopping_bag, color: Colors.pink),
    label: 'Produce',
  ),
  NavigationDestination(
    icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey),
    selectedIcon: Icon(Icons.shopping_cart, color: Colors.yellow),
    label: 'Cart',
  ),
  NavigationDestination(
    icon: Icon(Icons.account_circle_outlined, color: Colors.grey),
    selectedIcon: Icon(Icons.account_circle, color: Colors.orange),
    label: 'Profile',
  ),
];
