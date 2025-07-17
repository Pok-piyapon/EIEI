import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/storage.dart';

class MunicipalPinLockPage extends StatefulWidget {
  @override
  _MunicipalPinLockPageState createState() => _MunicipalPinLockPageState();
}

class _MunicipalPinLockPageState extends State<MunicipalPinLockPage> {
  String _enteredPin = '';
  final int _pinLength = 4;
  bool _isLoading = false;
  var _auth;
  var _pin;
  String currPin = '';

  Future<void> _load(BuildContext context) async {
    setState(() async {
      _auth = await AuthStorage.get('auth');
      _pin = await AuthStorage.get('user_pin');
      int data = 0;
      if (_auth != 'true') {
        context.go('/login');
      } else if (_pin != null) {
        currPin = _pin;
      } else {
        context.go('/security');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _load(context);
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
              SizedBox(height: 20),

              // Header
              _buildHeader(),

              Spacer(),

              // PIN Display
              _buildPinDisplay(),

              SizedBox(height: 40),

              // Number Pad
              _buildNumberPad(),

              Spacer(),

              SizedBox(height: 40),
            ],
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icon/icon.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 20),

        // Title
        Text(
          'เทศบาล',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'กรุณาใส่รหัส PIN 4 หลัก',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_pinLength, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < _enteredPin.length
                  ? Colors.white
                  : Colors.transparent,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),

          SizedBox(height: 25),

          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),

          SizedBox(height: 25),

          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),

          SizedBox(height: 25),

          // Row 4: Clear, 0, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(text: 'ล้าง', onPressed: _handleClear),
              _buildNumberButton('0'),
              _buildActionButton(
                icon: Icons.backspace_outlined,
                onPressed: _handleDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _handleNumberPress(number),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(
                  text ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleNumberPress(String number) {
    if (_enteredPin.length < _pinLength && !_isLoading) {
      setState(() {
        _enteredPin += number;
      });

      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Check if PIN is complete
      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _handleDelete() {
    if (_enteredPin.isNotEmpty && !_isLoading) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });

      // Add haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _handleClear() {
    if (_enteredPin.isNotEmpty && !_isLoading) {
      setState(() {
        _enteredPin = '';
      });

      // Add haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  void _verifyPin() {
    setState(() {
      _isLoading = true;
    });

    // Show loading indicator
    _showLoadingDialog();

    // Simulate PIN verification
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pop(); // Close loading dialog

      setState(() {
        _isLoading = false;
      });

      // Replace with your actual PIN verification logic
      if (_enteredPin == currPin) {
        // Success
        _showSuccessDialog();
      } else {
        // Failed
        _showErrorDialog();
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4A9F)),
                ),
                SizedBox(width: 20),
                Text(
                  'กำลังตรวจสอบ...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    HapticFeedback.heavyImpact();
    context.go('/');
  }

  void _showErrorDialog() {
    setState(() {
      _enteredPin = '';
    });

    // Add error haptic feedback
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 50),
                ),
                SizedBox(height: 20),
                Text(
                  'รหัส PIN ไม่ถูกต้อง',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'กรุณาลองใหม่อีกครั้ง',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'ลองอีกครั้ง',
                style: TextStyle(
                  color: Color(0xFF8B4A9F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
