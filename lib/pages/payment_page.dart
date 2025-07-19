import 'package:flutter/material.dart';
import 'package:flutter_appmypham/pages/Payment_Successful_Page.dart';

class CartPage extends StatelessWidget {
  final int userId; // ✅ Nhận userId từ ngoài truyền vào

  const CartPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Thanh Toán"),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: CartItemList()), // ✅ Đã đổi tên đúng class
            const CouponField(),
            const SummarySection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessfulPage(userId: userId),
                      ),
                    );
                  },
                  child: const Text("Thanh Toán"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Danh sách sản phẩm
class CartItemList extends StatelessWidget {
  const CartItemList();

  @override
  Widget build(BuildContext context) {
    final items = [
      ("Tẩy tế bào chết", "570 Ml", "assets/images/taytebaochet.jpg", "20.000đ"),
      ("Kem thoa tay", "330 Ml", "assets/images/kemthoatay.jpg", "10.000đ"),
      ("Xịt dưỡng tóc", "500 Ml", "assets/images/duongtoc.jpg", "12.000đ"),
    ];

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItem(
          name: item.$1,
          description: item.$2,
          imagePath: item.$3,
          price: item.$4,
        );
      },
    );
  }
}

class CartItem extends StatelessWidget {
  final String name;
  final String description;
  final String imagePath;
  final String price;

  const CartItem({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {},
                      ),
                      const Text("1"),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline),
          ],
        ),
      ),
    );
  }
}

class CouponField extends StatelessWidget {
  const CouponField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Nhập Voucher",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  const SummarySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SummaryRow(label: "Total Item", value: "6"),
          SummaryRow(label: "Số lượng", value: "3"),
          SummaryRow(label: "Thành tiền", value: "42.000đ"),
          SummaryRow(label: "Discount", value: "5.000đ"),
          const Divider(),
          SummaryRow(label: "Tổng hóa đơn", value: "37.000đ", isBold: true),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const SummaryRow({
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
