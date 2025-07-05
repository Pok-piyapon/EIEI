import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';

class MunicipalWebViewPage extends StatefulWidget {
  @override
  State<MunicipalWebViewPage> createState() => _MunicipalWebViewPageState();
}

class _MunicipalWebViewPageState extends State<MunicipalWebViewPage> {
  InAppWebViewController? webViewController;
  final dio = Dio();
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
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
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://c.webservicehouse.com/Homepage_mobile?KC=FSJ5w2rt'),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            iframeAllow: "camera; microphone",
            iframeAllowFullscreen: true,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onLoadStop: (controller, url) {
            setState(() {
              isLoading = false;
            });
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              isLoading = false;
              hasError = true;
            });
            print('WebView error: ${error.description}');
          },
          onReceivedHttpError: (controller, request, errorResponse) {
            setState(() {
              isLoading = false;
              hasError = true;
            });
            print('HTTP error: ${errorResponse.statusCode}');
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url.toString();
            print("Navigation requested: $url");
            
            if (url.contains("ticket_follow_form")) {
              try {
                final response = await dio.post(
                  'https://cloud-messaging.onrender.com/api/notification',
                  data: {
                    "title": "แจ้งเตือน",
                    "body": "มีการร้องเรียนเข้ามาใหม่",
                    "data": {
                      "action": "open_app",
                      "url": "https://example.com",
                    },
                    "imageUrl":
                        "https://images.unsplash.com/photo-1575936123452-b67c3203c357?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D",
                  },
                );
                print(response.data);
              } catch (e) {
                print('Error sending notification: $e');
              }
            }
            
            return NavigationActionPolicy.ALLOW;
          },
        ),
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

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
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
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _reloadWebView();
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

  void _reloadWebView() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    webViewController?.reload();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () {
              context.go('/');
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
                    webViewController?.reload();
                  } else {
                    _reloadWebView();
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