import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChangingPassword = false;
  bool _isChangingPin = false;
  String? _documentId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final documentId = await AuthStorage.get('user_document_id');
      if (documentId != null) {
        setState(() {
          _documentId = documentId;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B4A9F), Color(0xFFD577A7), Color(0xFFF5C4C4)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20),
                      _buildPasswordSection(),
                      SizedBox(height: 20),
                      _buildPinSection(),
                      SizedBox(height: 20),
                      _buildSecurityTips(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go('/profile'),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              ),
              Expanded(
                child: Text(
                  'ความปลอดภัย',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เปลี่ยนรหัสผ่าน',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'อัปเดตรหัสผ่านของคุณเพื่อความปลอดภัย',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_isChangingPassword) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'รหัสผ่านปัจจุบัน',
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'รหัสผ่านใหม่',
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'ยืนยันรหัสผ่านใหม่',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _buildPasswordActionButtons(),
                    ],
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPassword = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4A9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'เปลี่ยนรหัสผ่าน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.pin_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตั้งค่า PIN 4 หลัก',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'สร้าง PIN สำหรับเข้าถึงแอปพลิเคชันอย่างรวดเร็ว',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_isChangingPin) ...[
                Column(
                  children: [
                    SizedBox(height: 15),
                    _buildPinField(
                      controller: _newPinController,
                      label: 'PIN ใหม่ (4 หลัก)',
                    ),
                    SizedBox(height: 15),
                    _buildPinField(
                      controller: _confirmPinController,
                      label: 'ยืนยัน PIN ใหม่',
                    ),
                    SizedBox(height: 20),
                    _buildPinActionButtons(),
                  ],
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPin = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4A9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'ตั้งค่า PIN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTips() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.security, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'คำแนะนำด้านความปลอดภัย',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildSecurityTip(
                Icons.check_circle,
                'ใช้รหัสผ่านที่มีความซับซ้อน',
                'ควรมีตัวอักษรตัวใหญ่ เล็ก ตัวเลข และสัญลักษณ์',
              ),
              SizedBox(height: 15),
              _buildSecurityTip(
                Icons.check_circle,
                'อย่าแชร์รหัสผ่านหรือ PIN',
                'ไม่ควรเปิดเผยข้อมูลส่วนตัวให้ผู้อื่น',
              ),
              SizedBox(height: 15),
              _buildSecurityTip(
                Icons.check_circle,
                'เปลี่ยนรหัสผ่านเป็นประจำ',
                'ควรเปลี่ยนรหัสผ่านทุก 3-6 เดือน',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8B4A9F)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF8B4A9F), width: 2),
        ),
        labelStyle: TextStyle(color: Color(0xFF8B4A9F)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอก$label';
        }
        if (label.contains('รหัสผ่านใหม่') && value.length < 6) {
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        }
        if (label.contains('ยืนยันรหัสผ่านใหม่') &&
            value != _newPasswordController.text) {
          return 'รหัสผ่านไม่ตรงกัน';
        }
        return null;
      },
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: TextStyle(color: Colors.black87, fontSize: 16, letterSpacing: 8),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.pin_outlined, color: Color(0xFF8B4A9F)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF8B4A9F), width: 2),
        ),
        labelStyle: TextStyle(color: Color(0xFF8B4A9F)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (label.contains('ปัจจุบัน'))
            return null; // Current PIN is optional
          return 'กรุณากรอก$label';
        }
        if (value.length != 4) {
          return 'PIN ต้องมี 4 หลัก';
        }
        if (label.contains('ยืนยัน') && value != _newPinController.text) {
          return 'PIN ไม่ตรงกัน';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isChangingPassword = false;
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'ยกเลิก',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4A9F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'บันทึก',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isChangingPin = false;
                _newPinController.clear();
                _confirmPinController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'ยกเลิก',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _savePin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4A9F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'บันทึก',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _savePassword() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();

      try {
        if (_documentId == null) throw Exception('Document ID not found');

        final currentPasswordInput = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;

        // 1. Fetch user document
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_documentId)
            .get();

        if (!userDoc.exists) {
          Navigator.of(context).pop();
          _showErrorDialog('ไม่พบข้อมูลผู้ใช้');
          return;
        }

        final storedPassword = userDoc.data()?['password'];

        // 2. Compare current password
        if (currentPasswordInput != storedPassword) {
          Navigator.of(context).pop();
          _showErrorDialog('รหัสผ่านปัจจุบันไม่ถูกต้อง');
          return;
        }

        // 3. Ensure new password is different
        if (newPassword == storedPassword) {
          Navigator.of(context).pop();
          _showErrorDialog('รหัสผ่านใหม่ต้องไม่เหมือนรหัสผ่านเดิม');
          return;
        }

        // 4. Update password in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_documentId)
            .update({
              'password': newPassword, // You should hash this in production
              'updatedAt': FieldValue.serverTimestamp(),
            });

        Navigator.of(context).pop();
        _showSuccessDialog('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว');

        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } catch (e) {
        Navigator.of(context).pop();
        print('Error saving password: $e');
        _showErrorDialog('เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน');
      }
    }
  }

  void _savePin() async {
    if (_newPinController.text.length == 4 &&
        _newPinController.text == _confirmPinController.text) {
      _showLoadingDialog();

      try {
        // Save PIN to secure storage
        await AuthStorage.set('user_pin', _newPinController.text);

        // // You can also save to Firestore if needed
        // if (_documentId != null) {
        //   await FirebaseFirestore.instance
        //       .collection('users')
        //       .doc(_documentId)
        //       .update({
        //         'hasPinSet': true,
        //         'updatedAt': FieldValue.serverTimestamp(),
        //       });
        // }

        Navigator.of(context).pop(); // Close loading dialog
        _showSuccessDialog('ตั้งค่า PIN เรียบร้อยแล้ว');

        setState(() {
          _isChangingPin = false;
          _newPinController.clear();
          _confirmPinController.clear();
        });
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        print('Error saving PIN: $e');
        _showErrorDialog('เกิดข้อผิดพลาดในการตั้งค่า PIN');
      }
    } else {
      _showErrorDialog('กรุณาใส่ PIN ให้ถูกต้องและครบถ้วน');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4A9F)),
            ),
            SizedBox(width: 20),
            Text('กำลังบันทึกข้อมูล...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
