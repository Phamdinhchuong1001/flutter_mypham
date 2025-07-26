import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_appmypham/screens/product/admin_edit_product_screen.dart';
import '../../models/product.dart';
import '../../services/admin_product_service.dart';
import '../../utils/utils.dart';
import 'admin_add_product_screen.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final AdminProductService _productService = AdminProductService();

  final Color mainColor = const Color(0xFF162F4A);
  final Color accentColor = const Color(0xFF3A5F82);
  final Color lightColor = const Color(0xFF718EA4);
  final Color ultraLightColor = const Color(0xFFD0DCE7);

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

 Future<void> _fetchProducts() async {
  setState(() => _isLoading = true);
  try {
    final products = await _productService.getProducts();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    print('❌ [AdminProductScreen] Lỗi khi load sản phẩm: $e');
  }
}


  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xóa Sản Phẩm', style: TextStyle(color: mainColor)),
        content: Text('Bạn có chắc chắn muốn xóa "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _productService.deleteProduct(product.id!);
        await _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa "${product.name}"')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
            ).then((_) => _fetchProducts()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: mainColor,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: accentColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: _filterProducts,
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: mainColor))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text('Không có sản phẩm nào', style: TextStyle(color: lightColor)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => CircularProgressIndicator(),
                                  errorWidget: (_, __, ___) => Icon(Icons.error),
                                ),
                              ),
                              title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(Utils.formatCurrency(product.price), style: TextStyle(color: accentColor)),
                              trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.edit, color: accentColor),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminEditProductScreen(product: product),
          ),
        ).then((_) => _fetchProducts());
      },
    ),
    IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _deleteProduct(product),
    ),
  ],
),

                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
