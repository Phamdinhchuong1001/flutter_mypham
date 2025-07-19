import 'package:flutter/material.dart';
import 'home_page.dart';

class PaymentSuccessfulPage extends StatelessWidget {
  final int userId;

  const PaymentSuccessfulPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Thank you for your payment!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Đơn hàng của bạn đã được thanh toán.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
                );
              },
              child: const Text("Về trang chủ"),
            ),
          ],
        ),
      ),
    );
  }
}
