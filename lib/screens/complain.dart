import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MunicipalWebViewPage extends StatefulWidget {
  @override
  State<MunicipalWebViewPage> createState() => _MunicipalWebViewPageState();
}

class _MunicipalWebViewPageState extends State<MunicipalWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      // Initialize the WebView controller
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading progress if needed
            },
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                isLoading = false;
                hasError = true;
              });
              print('WebView error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Allow all navigation requests
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('https://c.webservicehouse.com/Homepage_mobile?KC=FSJ5w2rt'));
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('WebView initialization error: $e');
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
          child: Column(
            children: [
              // Header with municipal theme
              _buildHeader(context),
              
              // WebView Container
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildWebViewContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (hasError) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading) _buildLoadingState(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF8B4A9F),
              ),
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

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'ไม่สามารถโหลดหน้าเว็บได้',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _initializeWebView();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4A9F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_city, color: Color(0xFF8B4A9F)),
                ),
                SizedBox(width: 8),
                Text(
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
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white, size: 24),
                onPressed: () {
                  if (!hasError) {
                    controller.reload();
                  } else {
                    _initializeWebView();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.home, color: Colors.white, size: 24),
                onPressed: () {
                  context.go("/");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}