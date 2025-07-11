import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

class AppealFormPage extends StatefulWidget {
  @override
  _AppealFormPageState createState() => _AppealFormPageState();
}

class _AppealFormPageState extends State<AppealFormPage> with TickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _floatingActionController;
  
  // Animations
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _floatingPulseAnimation;
  
  bool _isSubmitting = false;
  bool _showSuccessAnimation = false;
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _appealTypeController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  List<File> _selectedImages = [];
  String _selectedAppealType = 'เลือกประเภทการอุทธรณ์';
  String _selectedLocation = 'เลือกตำแหน่ง';
  
  // Location variables
  double? _latitude;
  double? _longitude;
  String? _locationAddress;
  bool _isLoadingLocation = false;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  
  // Zip code functionality
  final Dio _dio = Dio();
  List<ZipCodeData> _zipCodeSuggestions = [];
  bool _isLoadingZipCode = false;
  Timer? _zipCodeDebounceTimer;
  
  // Notification URL
  final String _notificationUrl = 'https://cloud-messaging.onrender.com/api/notification';
  
  final List<String> _appealTypes = [
    'เลือกประเภทการอุทธรณ์',
    'อุทธรณ์ภาษี',
    'อุทธรณ์ใบอนุญาต',
    'อุทธรณ์การปรับ',
    'อุทธรณ์การบริการ',
    'อื่นๆ'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialAnimations();
  }

  void _setupAnimations() {
    // Header animation
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    // Card animation
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Floating action animation
    _floatingActionController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _floatingPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _floatingActionController,
      curve: Curves.easeInOut,
    ));
  }

  void _startInitialAnimations() {
    _headerAnimationController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
    Future.delayed(Duration(milliseconds: 400), () {
      _progressAnimationController.forward();
    });
  }

  Future<void> _searchZipCode(String query) async {
    if (query.length < 3) {
      setState(() {
        _zipCodeSuggestions.clear();
        _isLoadingZipCode = false;
      });
      return;
    }

    setState(() {
      _isLoadingZipCode = true;
    });

    try {
      final response = await _dio.get('https://c.webservicehouse.com/assets/homepage/th_zipcode.json');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<ZipCodeData> allZipCodes = data.map((json) => ZipCodeData.fromJson(json)).toList();
        
        // Filter based on query (zipcode, district, amphoe, or province)
        final List<ZipCodeData> filtered = allZipCodes.where((item) {
          return item.zipcode.contains(query) ||
                 item.district.toLowerCase().contains(query.toLowerCase()) ||
                 item.amphoe.toLowerCase().contains(query.toLowerCase()) ||
                 item.province.toLowerCase().contains(query.toLowerCase());
        }).take(10).toList(); // Limit to 10 results
        
        setState(() {
          _zipCodeSuggestions = filtered;
          _isLoadingZipCode = false;
        });
      }
    } catch (e) {
      setState(() {
        _zipCodeSuggestions.clear();
        _isLoadingZipCode = false;
      });
      print('Error fetching zip code data: $e');
    }
  }

  void _onAddressTextChanged(String value) {
    _zipCodeDebounceTimer?.cancel();
    _zipCodeDebounceTimer = Timer(Duration(milliseconds: 500), () {
      _searchZipCode(value);
    });
  }

  void _selectZipCodeSuggestion(ZipCodeData suggestion) {
    _addressController.text = suggestion.fullAddress;
    setState(() {
      _zipCodeSuggestions.clear();
    });
  }
  
  Future<void> _sendNotification() async {
    try {
      await _dio.post(_notificationUrl, data: {
        "title": "แจ้งเตือน",
        "body": "มีการร้องเรียนเข้ามาใหม่",
        "data": {"action": "open_app", "url": "https://example.com"},
        "imageUrl": "https://images.unsplash.com/photo-1575936123452-b67c3203c357?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D",
      });
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _appealTypeController.dispose();
    _contentController.dispose();
    _streetController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _longController.dispose();
    _pageController.dispose();
    
    // Cancel zip code timer
    _zipCodeDebounceTimer?.cancel();
    
    // Dispose animation controllers
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _progressAnimationController.dispose();
    _floatingActionController.dispose();
    
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
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildPersonalInfoStep(),
                    _buildAppealDetailsStep(),
                    _buildImageUploadStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          SizedBox(width: 8),
          Icon(
            Icons.gavel,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'แบบฟอร์มอุทธรณ์',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1}/4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Beautiful animated progress bar
          Row(
            children: List.generate(4, (index) {
              bool isActive = index <= _currentStep;
              bool isCurrent = index == _currentStep;
              
              return Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: isCurrent ? 8 : 6,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? (isCurrent ? Colors.white : Colors.white.withOpacity(0.7))
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12),
          // Step labels with icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel(0, Icons.person, 'ข้อมูล'),
              _buildStepLabel(1, Icons.description, 'รายละเอียด'),
              _buildStepLabel(2, Icons.image, 'รูปภาพ'),
              _buildStepLabel(3, Icons.check_circle, 'ตรวจสอบ'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepLabel(int step, IconData icon, String label) {
    bool isActive = step <= _currentStep;
    bool isCurrent = step == _currentStep;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent 
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isActive ? Color(0xFF8B4A9F) : Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('ข้อมูลส่วนบุคคล', 'กรอกข้อมูลส่วนตัวของท่าน'),
            SizedBox(height: 24),
            _buildFormCard([
              _buildTextField(
                controller: _firstNameController,
                label: 'ชื่อ',
                icon: Icons.person,
                hint: 'กรอกชื่อของท่าน',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'นามสกุล',
                icon: Icons.person_outline,
                hint: 'กรอกนามสกุลของท่าน',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'เบอร์โทรศัพท์',
                icon: Icons.phone,
                hint: 'กรอกเบอร์โทรศัพท์',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _buildAddressFieldWithSuggestions(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAppealDetailsStep() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('รายละเอียดการอุทธรณ์', 'กรอกข้อมูลเกี่ยวกับการอุทธรณ์'),
            SizedBox(height: 24),
            _buildFormCard([
              _buildDropdownField(
                value: _selectedAppealType,
                items: _appealTypes,
                label: 'ประเภทการอุทธรณ์',
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _selectedAppealType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _contentController,
                label: 'เนื้อหาการอุทธรณ์',
                icon: Icons.description,
                hint: 'อธิบายรายละเอียดการอุทธรณ์',
                maxLines: 5,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                label: 'ถนน/ซอย',
                icon: Icons.streetview,
                hint: 'กรอกชื่อถนนหรือซอย',
              ),
              SizedBox(height: 16),
              _buildLocationField(),
              SizedBox(height: 16),
              _buildCoordinatesDisplay(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadStep() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('อัพโหลดรูปภาพ', 'เพิ่มรูปภาพประกอบการอุทธรณ์ (สูงสุด 3 รูป)'),
            SizedBox(height: 24),
            _buildFormCard([
              _buildImageUploadSection(),
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(height: 20),
                _buildImagePreview(),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('ตรวจสอบข้อมูล', 'กรุณาตรวจสอบข้อมูลก่อนส่ง'),
            SizedBox(height: 24),
            _buildConfirmationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    // Different gradient colors for each step
    List<Color> stepColors = [
      [Color(0xFF6A5AE0), Color(0xFF9C88FF)], // Purple gradient
      [Color(0xFF42A5F5), Color(0xFF64B5F6)], // Blue gradient  
      [Color(0xFF26C6DA), Color(0xFF4DD0E1)], // Cyan gradient
      [Color(0xFF66BB6A), Color(0xFF81C784)], // Green gradient
    ][_currentStep];
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: stepColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stepColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              [Icons.person, Icons.description, Icons.image, Icons.check_circle][_currentStep],
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    // Colorful card backgrounds for each step
    Color cardColor = [
      Color(0xFFF3E5F5), // Light purple
      Color(0xFFE3F2FD), // Light blue
      Color(0xFFE0F2F1), // Light teal
      Color(0xFFE8F5E8), // Light green
    ][_currentStep];
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: [
            Color(0xFF6A5AE0),
            Color(0xFF42A5F5),
            Color(0xFF26C6DA),
            Color(0xFF66BB6A),
          ][_currentStep].withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: [
              Color(0xFF6A5AE0),
              Color(0xFF42A5F5),
              Color(0xFF26C6DA),
              Color(0xFF66BB6A),
            ][_currentStep].withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    // Dynamic colors based on current step
    Color accentColor = [
      Color(0xFF6A5AE0), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26C6DA), // Cyan
      Color(0xFF66BB6A), // Green
    ][_currentStep];
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: accentColor),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    Color accentColor = [
      Color(0xFF6A5AE0), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26C6DA), // Cyan
      Color(0xFF66BB6A), // Green
    ][_currentStep];
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accentColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: item == value ? accentColor : Colors.black87,
                fontWeight: item == value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLocationField() {
    Color accentColor = [
      Color(0xFF6A5AE0), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26C6DA), // Cyan
      Color(0xFF66BB6A), // Green
    ][_currentStep];
    
    return Column(
      children: [
        GestureDetector(
          onTap: _showLocationPicker,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  accentColor.withOpacity(0.1),
                ],
              ),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoadingLocation 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.location_on, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ตำแหน่ง',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isLoadingLocation 
                            ? 'กำลังชอตตำแหน่ง...'
                            : _selectedLocation,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedLocation == 'เลือกตำแหน่ง' 
                              ? Colors.grey.shade500 
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_locationAddress != null) ...[
                        SizedBox(height: 4),
                        Text(
                          _locationAddress!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
                ),
              ],
            ),
          ),
        ),
        if (_latitude != null && _longitude != null) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: accentColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${_latitude!.toStringAsFixed(6)}, Long: ${_longitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                      text: '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('คัดลอกพิกัดแล้ว'),
                        backgroundColor: accentColor,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.copy, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildAddressFieldWithSuggestions() {
    Color accentColor = [
      Color(0xFF6A5AE0), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26C6DA), // Cyan
      Color(0xFF66BB6A), // Green
    ][_currentStep];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            onChanged: _onAddressTextChanged,
            decoration: InputDecoration(
              labelText: 'ที่อยู่',
              hintText: 'กรอกรหัสไปรษณีย์ หรือชื่อแขวง จังหวัด',
              prefixIcon: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingZipCode 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      )
                    : Icon(Icons.home, color: accentColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: accentColor),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
        
        // Suggestions dropdown
        if (_zipCodeSuggestions.isNotEmpty) ...[
          SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _zipCodeSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _zipCodeSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.location_city,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  title: Text(
                    suggestion.fullAddress,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'ตำบล: ${suggestion.district} อำเภอ: ${suggestion.amphoe}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onTap: () => _selectZipCodeSuggestion(suggestion),
                );
              },
            ),
          ),
        ],
        
        if (_zipCodeSuggestions.isEmpty && !_isLoadingZipCode && _addressController.text.length >= 3) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                SizedBox(width: 8),
                Text(
                  'ไม่พบข้อมูลที่ตรงกัน',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildCoordinatesDisplay() {
    Color accentColor = [
      Color(0xFF6A5AE0), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26C6DA), // Cyan
      Color(0xFF66BB6A), // Green
    ][_currentStep];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.05),
            accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_location, color: accentColor),
              SizedBox(width: 8),
              Text(
                'แก้ไขพิกัดแม่นยำ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latController,
                  label: 'Latitude',
                  icon: Icons.place,
                  hint: 'เช่น 13.7563',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _longController,
                  label: 'Longitude',
                  icon: Icons.place,
                  hint: 'เช่น 100.5018',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _setManualLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.save_alt),
              label: Text('บันทึกพิกัด'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFF8B4A9F),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFF8B4A9F).withOpacity(0.05),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showImageSourceDialog,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: Color(0xFF8B4A9F),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'เพิ่มรูปภาพ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4A9F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'แตะเพื่อเลือกรูปภาพ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'สามารถอัพโหลดได้สูงสุด 3 รูป (JPG, PNG)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รูปภาพที่เลือก (${_selectedImages.length}/3)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4A9F),
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_selectedImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationCard() {
    return _buildFormCard([
      _buildConfirmationSection('ข้อมูลส่วนบุคคล', [
        _buildConfirmationItem('ชื่อ-นามสกุล', '${_firstNameController.text} ${_lastNameController.text}'),
        _buildConfirmationItem('เบอร์โทรศัพท์', _phoneController.text),
        _buildConfirmationItem('ที่อยู่', _addressController.text),
      ]),
      Divider(height: 32),
      _buildConfirmationSection('รายละเอียดการอุทธรณ์', [
        _buildConfirmationItem('ประเภท', _selectedAppealType),
        _buildConfirmationItem('เนื้อหา', _contentController.text),
        _buildConfirmationItem('ถนน/ซอย', _streetController.text),
        _buildConfirmationItem('ตำแหน่ง', _selectedLocation),
      ]),
      Divider(height: 32),
      _buildConfirmationSection('รูปภาพ', [
        _buildConfirmationItem('จำนวนรูป', '${_selectedImages.length} รูป'),
      ]),
    ]);
  }

  Widget _buildConfirmationSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4A9F),
          ),
        ),
        SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ย้อนกลับ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? _submitForm : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF8B4A9F),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: Text(
                _currentStep == 3 ? 'ส่งข้อมูล' : 'ถัดไป',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

Future<void> _showLocationPicker() async {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'เลือกตำแหน่ง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.my_location, color: Color(0xFF8B4A9F)),
                title: Text('ใช้ตำแหน่งปัจจุบัน'),
                onTap: () async {
                  Navigator.pop(context);
                  await _determinePosition();
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: Color(0xFF8B4A9F)),
                title: Text('เลือกจากแผนที่'),
                onTap: () {
                  Navigator.pop(context);
                  _showMapPicker();
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_location, color: Color(0xFF8B4A9F)),
                title: Text('กรอกพิกัดเอง'),
                onTap: () {
                  Navigator.pop(context);
                  _showManualCoordinateEntry();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเปิดใช้งาน Location Services')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('การอนุญาตตำแหน่งถูกปฏิเสธ')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('การอนุญาตตำแหน่งถูกปฏิเสธอย่างถาวร')),
      );
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _selectedLocation = 'Lat: ${_latitude!.toStringAsFixed(6)}, Long: ${_longitude!.toStringAsFixed(6)}';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถหาตำแหน่งปัจจุบันได้')),
      );
    }
  }

  void _setManualLocation() {
    double? lat = double.tryParse(_latController.text);
    double? lng = double.tryParse(_longController.text);
    
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกพิกัดให้ถูกต้อง'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _selectedLocation = 'พิกัดที่เลือก: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกพิกัดแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showMapPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLatitude: _latitude ?? 13.7563, // Default to Bangkok
          initialLongitude: _longitude ?? 100.5018,
          onLocationSelected: (lat, lng) {
            setState(() {
              _latitude = lat;
              _longitude = lng;
              _selectedLocation = 'เลือกจากแผนที่: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
            });
          },
        ),
      ),
    );
  }
  
  void _showManualCoordinateEntry() {
    // Pre-fill with current coordinates if available
    if (_latitude != null) _latController.text = _latitude!.toStringAsFixed(6);
    if (_longitude != null) _longController.text = _longitude!.toStringAsFixed(6);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_location, color: Color(0xFF26C6DA)),
                    SizedBox(width: 12),
                    Text(
                      'กรอกพิกัดแม่นยำ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26C6DA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _latController,
                  label: 'Latitude (ลินค์ดิตุด)',
                  icon: Icons.north,
                  hint: 'เช่น 13.756331',
                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _longController,
                  label: 'Longitude (ลินค์บอย)',
                  icon: Icons.east,
                  hint: 'เช่น 100.501765',
                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF26C6DA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF26C6DA), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'คุณสามารถคัดลอกพิกัดจาก Google Maps หรือแอปแผนที่อื่นๆ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF26C6DA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('ยกเลิก'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _setManualLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF26C6DA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('บันทึก'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceDialog() {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สามารถอัพโหลดได้สูงสุด 3 รูป'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'เลือกรูปภาพ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF8B4A9F)),
                title: Text('ถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF8B4A9F)),
                title: Text('เลือกจากแกลเลอรี'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _submitForm() {
    // Validate form
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedAppealType == 'เลือกประเภทการอุทธรณ์' ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Send notification
    _sendNotification();

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('ส่งข้อมูลสำเร็จ'),
          ],
        ),
        content: Text('ข้อมูลการอุทธรณ์ของท่านได้รับการบันทึกแล้ว\nทางเราจะติดต่อกลับภายใน 3-5 วันทำการ'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: Text(
              'ตกลง',
              style: TextStyle(
                color: Color(0xFF8B4A9F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Flutter Map picker screen using OpenStreetMap
class MapPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final Function(double, double) onLocationSelected;

  const MapPickerScreen({
    Key? key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _mapController = MapController();
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocation = point;
    });
  }

  void _confirmLocation() {
    widget.onLocationSelected(_selectedLocation.latitude, _selectedLocation.longitude);
    Navigator.pop(context);
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเปิดใช้งาน Location Services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('การอนุญาตตำแหน่งถูกปฏิเสธ')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      
      _mapController.move(currentLocation, 16.0);
      setState(() {
        _selectedLocation = currentLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถหาตำแหน่งปัจจุบันได้')),
      );
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'เลือกตำแหน่งจากแผนที่',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF42A5F5),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: _onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'webservicehouse.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: _selectedLocation,
                    child: Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Coordinates display card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF42A5F5)),
                      SizedBox(width: 8),
                      Text(
                        'พิกัดที่เลือก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('คัดลอกพิกัดแล้ว'),
                              backgroundColor: Color(0xFF42A5F5),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFF42A5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.copy, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF42A5F5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}\nLng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Current location button
          Positioned(
            top: 140,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF42A5F5),
              onPressed: _isLoadingCurrentLocation ? null : _moveToCurrentLocation,
              child: _isLoadingCurrentLocation 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                      ),
                    )
                  : Icon(Icons.my_location),
            ),
          ),
          
          // Bottom action buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'แตะที่แผนที่เพื่อเลือกตำแหน่ง',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('ยกเลิก'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('ยืนยันตำแหน่ง'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Zip code data model
class ZipCodeData {
  final String district;
  final String districtEng;
  final String amphoe;
  final String amphoeEng;
  final String province;
  final String provinceEng;
  final String zipcode;

  ZipCodeData({
    required this.district,
    required this.districtEng,
    required this.amphoe,
    required this.amphoeEng,
    required this.province,
    required this.provinceEng,
    required this.zipcode,
  });

  factory ZipCodeData.fromJson(Map<String, dynamic> json) {
    return ZipCodeData(
      district: json['district'] ?? '',
      districtEng: json['districtEng'] ?? '',
      amphoe: json['amphoe'] ?? '',
      amphoeEng: json['amphoeEng'] ?? '',
      province: json['province'] ?? '',
      provinceEng: json['provinceEng'] ?? '',
      zipcode: json['zipcode'] ?? '',
    );
  }

  String get fullAddress {
    return '$district, $amphoe, $province $zipcode';
  }
}
