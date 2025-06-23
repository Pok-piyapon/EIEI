import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "dart:convert";

import 'package:firebase_auth/firebase_auth.dart';

class MunicipalRegisterPage extends StatefulWidget {
  @override
  _MunicipalRegisterPageState createState() => _MunicipalRegisterPageState();
}

class _MunicipalRegisterPageState extends State<MunicipalRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  SizedBox(height: 40),
                  
                  // Header with back button
                  _buildHeader(),
                  
                  SizedBox(height: 30),
                  
                  // Registration Form
                  _buildRegistrationForm(),
                  
                  SizedBox(height: 20),
                  
                  // Login Link
                  _buildLoginLink(),
                  
                  SizedBox(height: 20),
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
        // Back button and title row
        Row(
          children: [
            IconButton(
              onPressed: () {
                context.go("/login");
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                'สมัครสมาชิก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 48), // Balance the back button
          ],
        ),
        
        SizedBox(height: 20),
        
        // Logo
        Container(
          width: 80,
          height: 80,
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
            size: 40,
          ),
        ),
        
        SizedBox(height: 16),
        
        Text(
          'เทศบาล',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 8),
        
        Text(
          'สร้างบัญชีใหม่เพื่อเข้าใช้งาน',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
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
            // First Name and Last Name Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อ',
                      hintText: 'ชื่อจริง',
                      prefixIcon: Icon(
                        Icons.person_outline,
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
                        return 'กรุณาใส่ชื่อ';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'นามสกุล',
                      hintText: 'นามสกุล',
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
                        return 'กรุณาใส่นามสกุล';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'อีเมล',
                hintText: 'example@email.com',
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
                hintText: 'อย่างน้อย 6 ตัวอักษร',
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
            
            SizedBox(height: 20),
            
            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                hintText: 'ใส่รหัสผ่านอีกครั้ง',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8B4A9F),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF8B4A9F),
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                  return 'กรุณายืนยันรหัสผ่าน';
                }
                if (value != _passwordController.text) {
                  return 'รหัสผ่านไม่ตรงกัน';
                }
                return null;
              },
            ),
            
            SizedBox(height: 20),
            
            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF8B4A9F),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'ฉันยอมรับ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showTermsDialog();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size(0, 0),
                        ),
                        child: Text(
                          'ข้อกำหนดและเงื่อนไข',
                          style: TextStyle(
                            color: Color(0xFF8B4A9F),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _acceptTerms ? () {
                  if (_formKey.currentState!.validate()) {
                    _handleRegister();
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4A9F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'สมัครสมาชิก',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'มีบัญชีอยู่แล้ว? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ข้อกำหนดและเงื่อนไข',
            style: TextStyle(color: Color(0xFF8B4A9F)),
          ),
          content: SingleChildScrollView(
            child: Text(
              'ข้อกำหนดและเงื่อนไขการใช้งานระบบเทศบาลเมืองร้อยเอ็ด\n\n'
              '1. ผู้ใช้งานต้องให้ข้อมูลที่ถูกต้องและครบถ้วน\n'
              '2. ไม่นำข้อมูลส่วนบุคคลไปใช้ในทางที่ผิด\n'
              '3. รักษาความปลอดภัยของบัญชีผู้ใช้\n'
              '4. ใช้งานระบบด้วยความเหมาะสม\n'
              '5. ปฏิบัติตามกฎหมายและระเบียบที่เกี่ยวข้อง\n\n'
              'เทศบาลขอสงวนสิทธิ์ในการเปลี่ยนแปลงข้อกำหนดโดยไม่ต้องแจ้งให้ทราบล่วงหน้า',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'ปิด',
                style: TextStyle(color: Color(0xFF8B4A9F)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleRegister() async {
    // Show loading dialog
    await signUp(_emailController.text,_passwordController.text);

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
              Text('กำลังสมัครสมาชิก...'),
            ],
          ),
        );
      },
    );

    // Simulate registration process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text('สมัครสมาชิกสำเร็จ'),
              ],
            ),
            content: Text(
              'ยินดีต้อนรับสู่เทศบาลเมืองร้อยเอ็ด\nโปรดเข้าสู่ระบบเพื่อใช้งาน',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close success dialog
                },
                child: Text(
                  'ตกลง',
                  style: TextStyle(color: Color(0xFF8B4A9F)),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}




Future<bool> signUp(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    print("❌ Sign up error: ${e.message}");
    return false;
  }
}