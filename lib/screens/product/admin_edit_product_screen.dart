import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../../models/product.dart';
import '../../services/admin_product_service.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/utils.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late String _imageUrl;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  final AdminProductService _productService = AdminProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _isLoading = false;

  final Color mainColor = const Color(0xFF162F4A);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageUrl = widget.product.image;
  }

Future<void> _pickImage() async {
  final imageBytes = await ImagePickerWeb.getImageAsBytes();

  if (imageBytes != null) {
    setState(() {
      _selectedImageBytes = imageBytes;
      _selectedImageName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }
}


  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String finalImageUrl = _imageUrl;

    if (_selectedImageBytes != null && _selectedImageName != null) {
      final uploadedUrl = await _cloudinaryService.uploadImage(
        _selectedImageBytes!,
        fileName: _selectedImageName!,
      );
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Lỗi khi upload ảnh'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      image: finalImageUrl,
    );

    final success = await _productService.updateProduct(updatedProduct);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật sản phẩm thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi khi cập nhật sản phẩm'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, height: 200, fit: BoxFit.cover);
    } else {
      return Image.network(_imageUrl, height: 200, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              // Giá
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                decoration: const InputDecoration(
                  labelText: 'Giá sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả sản phẩm',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Ảnh
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImagePreview(),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Chọn ảnh mới'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(' Lưu thay đổi', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
