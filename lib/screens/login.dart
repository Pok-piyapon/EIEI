import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../services/storage.dart';

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
  final _store = AuthStorage();

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
          'เทศบาล',
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
                    _handleForgotPassword();
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

  void _handleLogin() async {
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

    try {
      // Authenticate using Firestore only
      Map<String, dynamic>? userData = await getUserDataFromFirestore(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (userData != null) {
        // Save user data to local storage
        await _saveUserDataToLocalStorage(userData);
        
        // Set authentication status
        await AuthStorage.set('auth', 'true');
        
        // Save remember me preference
        if (_rememberMe) {
          await AuthStorage.set('remember_me', 'true');
          await AuthStorage.set('saved_email', _emailController.text.trim());
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home
        await Future.delayed(const Duration(seconds: 1));
        context.go('/');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเข้าสู่ระบบ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleForgotPassword() {
    // Show dialog for password reset
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: Text('ลืมรหัสผ่าน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน'),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมลของคุณ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle password reset request
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('คำขอรีเซ็ตรหัสผ่านถูกส่งแล้ว'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('ส่งคำขอ'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getUserDataFromFirestore(
      String email, String password) async {
    try {
      // Query Firestore for user with matching email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        
        // Verify password (assuming plain text comparison)
        // Note: In production, you should hash passwords
        if (userData['password'] == password) {
          // Add document ID to user data
          userData['documentId'] = doc.id;
          
          return userData;
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
      return null;
    }
  }

  Future<void> _saveUserDataToLocalStorage(Map<String, dynamic> userData) async {
    try {
      // Save individual user data fields based on your Firestore structure
      await AuthStorage.set('user_document_id', userData['documentId'] ?? '');
      await AuthStorage.set('user_id', userData['id'] ?? '');
      await AuthStorage.set('user_email', userData['email'] ?? '');
      await AuthStorage.set('user_firstname', userData['firstname'] ?? '');
      await AuthStorage.set('user_lastname', userData['lastname'] ?? '');
      await AuthStorage.set('user_profile', userData['profile'] ?? 'default.jpg');
      await AuthStorage.set('user_created_at', userData['createdAt']?.toString() ?? '');
      
      // Save complete user data as JSON string if needed
      await AuthStorage.set('user_data', jsonEncode(userData));
      
      print('✅ User data saved to local storage successfully');
    } catch (e) {
      print('❌ Error saving user data to local storage: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  void _loadSavedEmail() async {
    try {
      String? rememberMe = await AuthStorage.get('remember_me');
      String? savedEmail = await AuthStorage.get('saved_email');
      
      if (rememberMe == 'true' && savedEmail != null) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error loading saved email: $e');
    }
  }
}

// Legacy function for backward compatibility - now uses Firestore only
Future<bool> signIn(String email, String password) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      
      // Verify password
      if (userData['password'] == password) {
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print("❌ Sign in error: $e");
    return false;
  }
}