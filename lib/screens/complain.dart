import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MunicipalWebViewPage extends StatefulWidget {
  @override
  State<MunicipalWebViewPage> createState() => _MunicipalWebViewPageState();
}

class _MunicipalWebViewPageState extends State<MunicipalWebViewPage> {
  late final WebViewController _controller;
  final _dio = Dio();
  final _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _hasError = false;

  static const _url = 'https://c.webservicehouse.com/Homepage_mobile?KC=FSJ5w2rt';
  static const _notificationUrl = 'https://cloud-messaging.onrender.com/api/notification';
  static const _primaryColor = Color(0xFF8B4A9F);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _setState(isLoading: true, hasError: false),
        onPageFinished: (_) => _setState(isLoading: false),
        onWebResourceError: (e) => _setState(isLoading: false, hasError: true),
        onNavigationRequest: _handleNavigation,
      ))
      ..loadRequest(Uri.parse(_url));

    // Configure Android WebView for file uploads
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      AndroidWebViewController androidController = _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      
      // Enable file upload functionality
      androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  // File picker for Android - Fixed to properly return file paths
  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    try {
      // Show options for camera, gallery, or file picker
      final result = await _showFilePickerDialog();
      
      if (result != null && result.isNotEmpty) {
        // Filter out any null paths and return valid file paths
        return result.where((path) => path != null && path.isNotEmpty).toList();
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
    return [];
  }

  // Show dialog to choose file source - Fixed to properly handle async operations
  Future<List<String>?> _showFilePickerDialog() async {
    return showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกไฟล์'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูป'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await _pickImageFromCamera();
                  if (result != null) {
                    // Return the result to the dialog caller
                    Navigator.pop(context, [result]);
                  } else {
                    Navigator.pop(context, <String>[]);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกจากแกลเลอรี'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await _pickImageFromGallery();
                  if (result != null) {
                    Navigator.pop(context, [result]);
                  } else {
                    Navigator.pop(context, <String>[]);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('เลือกไฟล์'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await _pickFile();
                  if (result != null && result.isNotEmpty) {
                    Navigator.pop(context, result);
                  } else {
                    Navigator.pop(context, <String>[]);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, <String>[]),
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  // Pick image from camera
  Future<String?> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Camera picker error: $e');
      _showErrorSnackBar('ไม่สามารถเปิดกล้องได้: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<String?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      _showErrorSnackBar('ไม่สามารถเลือกรูปภาพได้: $e');
      return null;
    }
  }

  // Pick any file
  Future<List<String>?> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        allowedExtensions: null,
      );

      if (result != null) {
        return result.paths.where((path) => path != null).cast<String>().toList();
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      _showErrorSnackBar('ไม่สามารถเลือกไฟล์ได้: $e');
    }
    return null;
  }

  // Show error message to user
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _setState({bool? isLoading, bool? hasError}) {
    if (mounted) {
      setState(() {
        if (isLoading != null) _isLoading = isLoading;
        if (hasError != null) _hasError = hasError;
      });
    }
  }

  Future<NavigationDecision> _handleNavigation(NavigationRequest request) async {
    if (request.url.contains("ticket_follow_form")) {
      _sendNotification();
    }
    return NavigationDecision.navigate;
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

  void _reload() {
    _setState(isLoading: true, hasError: false);
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B4A9F), Color(0xFFD577A7), Color(0xFFF5C4C4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => context.go('/'), onReload: _reload),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) return _ErrorView(onRetry: _reload);
    
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const _LoadingView(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onReload;

  const _Header({required this.onBack, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_city, color: Color(0xFF8B4A9F)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'เทศบาล',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onReload,
              ),
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () => context.go("/"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4A9F)),
            ),
            SizedBox(height: 16),
            Text(
              'กำลังโหลด...',
              style: TextStyle(
                color: Color(0xFF8B4A9F),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              'ไม่สามารถโหลดหน้าเว็บได้',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4A9F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }
}