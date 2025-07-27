import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các provider
import 'package:flutter_appmypham/auth/login_or_register.dart';
import 'package:flutter_appmypham/themes/theme_provider.dart';
import 'package:flutter_appmypham/providers/favorite_provider.dart';
import 'package:flutter_appmypham/providers/cart_provider.dart';
import 'package:flutter_appmypham/providers/product_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
