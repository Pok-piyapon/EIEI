import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';


class MunicipalHomePage extends StatelessWidget {
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
              // Header
              _buildHeader(context),
              
              // Notification Card
              _buildNotificationCard(),
              
              // Action Buttons
              _buildActionButtons(),
              
              // Feature Grid
              Expanded(
                child: _buildFeatureGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(Icons.menu, color: Colors.white, size: 24),
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
                  'เทศบาลเมืองร้อยเอ็ด',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
  			icon: Icon(Icons.refresh, color: Colors.white, size: 24),
  			onPressed: () {
    		// TODO: Your action here
    			context.go("/login");
  			},
		)
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.orange.shade100,
            ),
            child: Icon(Icons.event, color: Colors.orange, size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'วันแม่ แห่งชาติ ประจำปี 2567',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'วันอาทิตย์ที่ 12 สิงหาคม 2567 เวลา 07.30 น.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'หมวดหมู่ : ข่าวสาร/กิจกรรม',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
                Text(
                  'วันที่ : 12 ส.ค. 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'อ่านต่อ',
            style: TextStyle(
              color: Color(0xFF8B4A9F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.notifications, 'แจ้งเหตุกเหน'),
          _buildActionButton(Icons.campaign, 'ร้องเรียน'),
          _buildActionButton(Icons.phone_disabled, 'สายด่วน'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF8B4A9F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF8B4A9F), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.article, 'label': 'ข่าวสาร'},
      {'icon': Icons.slideshow, 'label': 'บทความ'},
      {'icon': Icons.videocam, 'label': 'CCTV'},
      {'icon': Icons.emoji_events, 'label': 'รางวัลที่แดนได้รับ'},
      {'icon': Icons.play_circle, 'label': 'Youtube'},
      {'icon': Icons.help_outline, 'label': 'ช่วยเหลือ'},
      {'icon': Icons.tour, 'label': 'ท่องเที่ยว'},
      {'icon': Icons.stop_circle, 'label': 'สินค้า OTOP'},
    ];

    return Container(
      margin: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureItem(
            feature['icon'] as IconData,
            feature['label'] as String,
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF8B4A9F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Color(0xFF8B4A9F),
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}