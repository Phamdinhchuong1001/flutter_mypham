import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import '../../models/product.dart';
import '../../services/admin_product_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker_web/image_picker_web.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({Key? key}) : super(key: key);

  @override
  _AdminAddProductScreenState createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  // 🎨 Màu sắc
  final Color mainColor = Color(0xFF162F4A);
  final Color accentColor = Color(0xFF3A5F82);
  final Color lightColor = Color(0xFF718EA4);
  final Color ultraLightColor = Color(0xFFD0DCE7);

  final _formKey = GlobalKey<FormState>();
  final AdminProductService _productService = AdminProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Uint8List? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
      if (imageBytes != null) {
        setState(() {
          _imageFile = imageBytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn ảnh: $e');
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isUploading = true);

        if (_imageFile == null) {
          _showErrorSnackBar('Vui lòng chọn ảnh sản phẩm');
          setState(() => _isUploading = false);
          return;
        }

        String? imageUrl = await _cloudinaryService.uploadImage(
          _imageFile!,
          fileName: 'product_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (imageUrl == null) {
          _showErrorSnackBar('Lỗi tải ảnh lên');
          setState(() => _isUploading = false);
          return;
        }

        final newProduct = Product(
          id: 0,
          name: _nameController.text,
          image: imageUrl,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
        );

        await _productService.addProduct(newProduct);

        _showSuccessSnackBar('Thêm sản phẩm thành công');
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('Lỗi thêm sản phẩm: $e');
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: mainColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: lightColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: suffixIcon,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ultraLightColor,
      appBar: AppBar(
        title: Text('Thêm Sản Phẩm Mới',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.white, size: 28),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hình ảnh
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: ultraLightColor,
                                  border: Border.all(color: lightColor, width: 1),
                                ),
                                child: _imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.memory(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt,
                                              size: 50, color: accentColor),
                                          SizedBox(height: 10),
                                          Text('Chọn Hình Ảnh',
                                              style: TextStyle(
                                                  color: accentColor,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Tên
                            TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration('Tên Sản Phẩm'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
                            ),
                            SizedBox(height: 16),

                            // Mô tả
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: _buildInputDecoration('Mô Tả'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                            ),
                            SizedBox(height: 16),

                            // Giá
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                'Giá (VNĐ)',
                                suffixIcon:
                                    Icon(Icons.attach_money, color: accentColor),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Vui lòng nhập giá' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Nút
                    ElevatedButton(
                      onPressed: _isUploading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        disabledBackgroundColor: lightColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Đang Xử Lý...',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            )
                          : Text(
                              'Thêm Sản Phẩm',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Overlay loading
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải lên sản phẩm...',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: mainColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
