import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MunicipalLoginPage extends StatefulWidget {
  @override
  _MunicipalLoginPageState createState() => _MunicipalLoginPageState();
}

class _MunicipalLoginPageState extends State<MunicipalLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B4A9F),
              Color(0xFFD577A7),
              Color(0xFFF5C4C4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: 60),
                  
                  // Logo and Title
                  _buildHeader(),
                  
                  SizedBox(height: 40),
                  
                  // Login Form
                  _buildLoginForm(),
                  
                  SizedBox(height: 20),
                  
                  // Additional Options
                  _buildAdditionalOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.location_city,
            color: Color(0xFF8B4A9F),
            size: 50,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Title
        Text(
          'เทศบาลเมืองร้อยเอ็ด',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 8),
        
        Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'อีเมล',
                hintText: 'กรุณาใส่อีเมลของคุณ',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF8B4A9F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF8B4A9F), width: 2),
                ),
                labelStyle: TextStyle(color: Color(0xFF8B4A9F)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาใส่อีเมล';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
            ),
            
            SizedBox(height: 20),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                hintText: 'กรุณาใส่รหัสผ่านของคุณ',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8B4A9F),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF8B4A9F),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF8B4A9F), width: 2),
                ),
                labelStyle: TextStyle(color: Color(0xFF8B4A9F)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาใส่รหัสผ่าน';
                }
                if (value.length < 6) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Remember Me & Forgot Password
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF8B4A9F),
                ),
                Text(
                  'จดจำฉันไว้',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(
                      color: Color(0xFF8B4A9F),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle login
                    _handleLogin();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4A9F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'หรือ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
          ],
        ),
        
        SizedBox(height: 20),
        SizedBox(height: 16),
        
        // Register Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ยังไม่มีบัญชี? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: Text(
                'สมัครสมาชิก',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
      ],
    );
  }

  void _handleLogin() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4A9F)),
              ),
              SizedBox(width: 20),
              Text('กำลังเข้าสู่ระบบ...'),
            ],
          ),
        );
      },
    );

    // Simulate login process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เข้าสู่ระบบสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to home page or handle successful login
    });
  }

  //void _handleGuestLogin() {
  //  // Navigate to home page as guest
  //  ScaffoldMessenger.of(context).showSnackBar(
  //    SnackBar(
  //      content: Text('เข้าใช้งานในฐานะผู้เยี่ยมชม'),
  //      backgroundColor: Color(0xFF8B4A9F),
  //    ),
  //  );
  //}
}