import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage.dart';

class MunicipalProfilePage extends StatefulWidget {
  final String? userId; // Pass user ID from parent widget/router
  
  const MunicipalProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _MunicipalProfilePageState createState() => _MunicipalProfilePageState();
}

class _MunicipalProfilePageState extends State<MunicipalProfilePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  String? _profileImageUrl;
  String? _userId;
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
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load from secure storage first
      final documentId = await AuthStorage.get('user_document_id');
      final userId = await AuthStorage.get('user_id');
      final email = await AuthStorage.get('user_email');
      final firstName = await AuthStorage.get('user_firstname');
      final lastName = await AuthStorage.get('user_lastname');
      final profile = await AuthStorage.get('user_profile');
      
      if (documentId != null) {
        _documentId = documentId;
        _userId = userId;
        _emailController.text = email ?? '';
        _firstNameController.text = firstName ?? '';
        _lastNameController.text = lastName ?? '';
        _profileImageUrl = profile != null && profile != 'default.jpg' ? profile : null;
      }

      // Load from Firestore for most up-to-date data if documentId exists
      if (_documentId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_documentId)
            .get();
            
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            // Update form fields with Firestore data
            _emailController.text = data['email'] ?? '';
            _firstNameController.text = data['firstname'] ?? '';
            _lastNameController.text = data['lastname'] ?? '';
            _profileImageUrl = data['profile'] != null && data['profile'] != 'default.jpg' ? data['profile'] : null;
            
            // Update secure storage with latest data
            await AuthStorage.set('user_email', data['email'] ?? '');
            await AuthStorage.set('user_firstname', data['firstname'] ?? '');
            await AuthStorage.set('user_lastname', data['lastname'] ?? '');
            await AuthStorage.set('user_profile', data['profile'] ?? 'default.jpg');
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showErrorDialog('เกิดข้อผิดพลาดในการโหลดข้อมูล');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            colors: [
              Color(0xFF8B4A9F),
              Color(0xFFD577A7),
              Color(0xFFF5C4C4),
            ],
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
                      _buildProfileCard(),
                      SizedBox(height: 20),
                      _buildMenuOptions(),
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
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  'โปรไฟล์ของฉัน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    key: ValueKey(_isEditing),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfilePicture(),
                SizedBox(height: 30),
                _buildProfileForm(),
                if (_isEditing) ...[
                  SizedBox(height: 30),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF8B4A9F).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _profileImageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(0xFF8B4A9F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'ชื่อ',
          icon: Icons.person_outline,
          enabled: _isEditing,
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: _lastNameController,
          label: 'นามสกุล',
          icon: Icons.person_outline,
          enabled: _isEditing,
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          label: 'อีเมล',
          icon: Icons.email_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey.shade600,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: enabled ? Color(0xFF8B4A9F) : Colors.grey.shade400,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          labelStyle: TextStyle(
            color: enabled ? Color(0xFF8B4A9F) : Colors.grey.shade500,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณากรอก$label';
          }
          if (label == 'อีเมล' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'รูปแบบอีเมลไม่ถูกต้อง';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                _isEditing = false;
              });
              // Reset form fields to original values
              await _loadUserData();
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
            onPressed: _saveProfile,
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

  Widget _buildMenuOptions() {
    final menuItems = [
      {
        'icon': Icons.security,
        'title': 'ความปลอดภัย',
        'subtitle': 'การตั้งค่าความปลอดภัย',
        'onTap': () => _showSecurityDialog(),
      },
      {
        'icon': Icons.notifications,
        'title': 'การแจ้งเตือน',
        'subtitle': 'ตั้งค่าการแจ้งเตือนและการพุชข้อความ',
        'onTap': () => _showNotificationSettings(),
      },
      {
        'icon': Icons.help_outline,
        'title': 'ช่วยเหลือและสนับสนุน',
        'subtitle': 'คำถามที่พบบ่อยและติดต่อเรา',
        'onTap': () => _showHelpDialog(),
      },
      {
        'icon': Icons.logout,
        'title': 'ออกจากระบบ',
        'subtitle': 'ออกจากระบบการใช้งาน',
        'onTap': () => _logout(),
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Material(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: item['onTap'] as VoidCallback,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
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
                            item['icon'] as IconData,
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
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade400,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('เลือกจากแกลเลอรี'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _profileImage = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('ถ่ายรูป'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _profileImage = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      
      try {
        if (_documentId == null) {
          throw Exception('Document ID not found');
        }

        // Prepare updated data
        final updatedData = {
          'firstname': _firstNameController.text,
          'lastname': _lastNameController.text,
          'email': _emailController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Note: Image upload functionality would need to be implemented
        // if you want to support profile image uploads
        
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_documentId)
            .update(updatedData);

        // Update secure storage
        await AuthStorage.set('user_email', _emailController.text);
        await AuthStorage.set('user_firstname', _firstNameController.text);
        await AuthStorage.set('user_lastname', _lastNameController.text);

        Navigator.of(context).pop(); // Close loading dialog
        _showSuccessDialog();
        
        setState(() {
          _isEditing = false;
          _profileImage = null; // Clear the selected image
        });
        
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        print('Error saving profile: $e');
        _showErrorDialog('เกิดข้อผิดพลาดในการบันทึกข้อมูล: ${e.toString()}');
      }
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

  void _showSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อย'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSecurityDialog() {
    context.go('/security');
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('การแจ้งเตือน'),
        content: Text('การตั้งค่าการแจ้งเตือนจะเปิดให้ใช้งานเร็วๆ นี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await AuthStorage.clearTokens();
    context.go('/login');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ช่วยเหลือและสนับสนุน'),
        content: Text('หากคุณมีคำถามหรือต้องการความช่วยเหลือ กรุณาติดต่อเราที่ support@municipal.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}