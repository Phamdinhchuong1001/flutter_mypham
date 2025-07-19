import 'package:flutter/material.dart';
import 'package:flutter_appmypham/services/api_service.dart'; // ✅ Gọi API
import 'package:flutter_appmypham/services/user_storage.dart'; // ✅ Lưu user vào local
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ✅ Hàm xử lý đăng ký
  void _register() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = email.split('@')[0];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final error = await ApiService.register(name, email, password);

    if (!mounted) return;
    Navigator.pop(context); // ❌ Đóng loading

    if (error == null) {
      // ✅ Đăng ký xong thì đăng nhập để lấy dữ liệu
      final loginResult = await ApiService.login(email, password);

      if (loginResult['success'] == true && loginResult['data'] != null) {
        await UserStorage.saveUserData(loginResult['data']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đăng ký thành công')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: loginResult['data']['id']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResult['message'] ?? 'Không thể đăng nhập sau khi đăng ký'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $error')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isSmallScreen
            ? SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFormContent(),
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    const Expanded(child: _Logo()),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildFormContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 🧱 Form đăng ký
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Logo(),
        const SizedBox(height: 5),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Đăng ký",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),

              // 🟡 Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                  final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$")
                      .hasMatch(value);
                  if (!emailValid) return 'Email không hợp lệ';
                  return null;
                },
                decoration: _inputDecoration("Email", Icons.email),
              ),
              const SizedBox(height: 16),

              // 🟡 Mật khẩu
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
                  return null;
                },
                decoration: _inputDecoration(
                  "Mật khẩu",
                  Icons.lock,
                  suffix: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🟡 Xác nhận mật khẩu
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
                decoration: _inputDecoration(
                  "Xác nhận mật khẩu",
                  Icons.lock_reset,
                  suffix: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🔵 Nút đăng ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00BF6D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Đăng ký"),
                ),
              ),
              const SizedBox(height: 16),

              // 🔁 Chuyển sang đăng nhập
              TextButton(
                onPressed: widget.onTap,
                child: Text.rich(
                  const TextSpan(
                    text: "Đã có tài khoản? ",
                    children: [
                      TextSpan(
                        text: "Đăng nhập",
                        style: TextStyle(color: Color(0xFF00BF6D)),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Color.fromRGBO(0, 0, 0, 0.64),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5FCF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/cocoon_logo.gif',
          height: 200,
        ),
        const SizedBox(height: 1),
      ],
    );
  }
}
