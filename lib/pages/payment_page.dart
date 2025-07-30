import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'payment_successful_page.dart';

class PaymentPage extends StatelessWidget {
  final int userId;
  final double totalPrice;
  final List<Product> cartItems;

  const PaymentPage({
    super.key,
    required this.userId,
    required this.totalPrice,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    int totalQuantity = cartItems.fold(0, (sum, item) => sum + item.quantity);
    double sumTotal = cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Thanh Toán"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(item.image),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        cartProvider.decreaseQuantity(item);
                                      },
                                    ),
                                    Text(item.quantity.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        cartProvider.increaseQuantity(item);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Text("${(item.price * item.quantity).toStringAsFixed(0)}đ",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              cartProvider.removeFromCart(item);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  SummaryRow(label: "Total Item", value: "${cartItems.length}"),
                  SummaryRow(label: "Số lượng", value: "$totalQuantity"),
                  SummaryRow(label: "Thành tiền", value: "${sumTotal.toStringAsFixed(0)}đ"),
                  const Divider(),
                  SummaryRow(label: "Tổng hóa đơn", value: "${sumTotal.toStringAsFixed(0)}đ", isBold: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final url = Uri.parse('http://172.20.10.5:3000/api/orders');

                        final items = cartItems.map((item) => {
                              'productId': item.id,
                              'quantity': item.quantity,
                              'price': item.price,
                            }).toList();

                        final body = {
                          'userId': userId,
                          'totalPrice': totalPrice,
                          'items': items,
                        };

                        try {
                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(body),
                          );

                          if (response.statusCode == 201) {
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentSuccessfulPage(userId: userId),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('❌ Đặt hàng thất bại: ${response.body}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Lỗi kết nối máy chủ')),
                          );
                        }
                      },
                      child: const Text("Thanh Toán"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
