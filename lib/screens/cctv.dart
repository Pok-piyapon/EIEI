import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MunicipalCCTVPage extends StatefulWidget {
  @override
  _MunicipalCCTVPageState createState() => _MunicipalCCTVPageState();
}

class _MunicipalCCTVPageState extends State<MunicipalCCTVPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'ทั้งหมด';

  // Sample CCTV data
  final List<CctvCamera> _cctvList = [
    CctvCamera(
      id: '001',
      name: 'กล้องหน้าศาลาว่าการ',
      location: 'ถนนเทศบาล 1',
      status: 'ออนไลน์',
      lastUpdate: '2 นาทีที่แล้ว',
      type: 'HD',
    ),
    CctvCamera(
      id: '002',
      name: 'กล้องสวนสาธารณะ',
      location: 'สวนเทศบาล',
      status: 'ออนไลน์',
      lastUpdate: '1 นาทีที่แล้ว',
      type: '4K',
    ),
    CctvCamera(
      id: '003',
      name: 'กล้องสี่แยกใหญ่',
      location: 'สี่แยกเทศบาล',
      status: 'ออฟไลน์',
      lastUpdate: '15 นาทีที่แล้ว',
      type: 'HD',
    ),
    CctvCamera(
      id: '004',
      name: 'กล้องตลาดเทศบาล',
      location: 'ตลาดเทศบาล',
      status: 'ออนไลน์',
      lastUpdate: '3 นาทีที่แล้ว',
      type: 'HD',
    ),
    CctvCamera(
      id: '005',
      name: 'กล้องสถานีขนส่ง',
      location: 'สถานีขนส่งเทศบาล',
      status: 'บำรุงรักษา',
      lastUpdate: '1 ชั่วโมงที่แล้ว',
      type: '4K',
    ),
    CctvCamera(
      id: '006',
      name: 'กล้องถนนสายหลัก',
      location: 'ถนนเทศบาล 2',
      status: 'ออนไลน์',
      lastUpdate: '30 วินาทีที่แล้ว',
      type: 'HD',
    ),
  ];

  List<CctvCamera> get _filteredCctvList {
    List<CctvCamera> filtered = _cctvList;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cctv) =>
          cctv.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cctv.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by status
    if (_selectedFilter != 'ทั้งหมด') {
      filtered = filtered.where((cctv) => cctv.status == _selectedFilter).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              _buildSearchAndFilter(),
              _buildStatusSummary(),
              Expanded(child: _buildCctvList()),
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
            onPressed: () {
              context.go('/');
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.videocam,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'กล้องวงจรปิด',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                // Refresh data
              });
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหากล้องหรือสถานที่...',
              prefixIcon: Icon(
                Icons.search,
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
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          SizedBox(height: 16),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ทั้งหมด'),
                SizedBox(width: 8),
                _buildFilterChip('ออนไลน์'),
                SizedBox(width: 8),
                _buildFilterChip('ออฟไลน์'),
                SizedBox(width: 8),
                _buildFilterChip('บำรุงรักษา'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Color(0xFF8B4A9F).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFF8B4A9F) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Color(0xFF8B4A9F) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStatusSummary() {
    final onlineCount = _cctvList.where((c) => c.status == 'ออนไลน์').length;
    final offlineCount = _cctvList.where((c) => c.status == 'ออฟไลน์').length;
    final maintenanceCount = _cctvList.where((c) => c.status == 'บำรุงรักษา').length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'ออนไลน์',
              onlineCount.toString(),
              Colors.green,
              Icons.videocam,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'ออฟไลน์',
              offlineCount.toString(),
              Colors.red,
              Icons.videocam_off,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'บำรุงรักษา',
              maintenanceCount.toString(),
              Colors.orange,
              Icons.build,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCctvList() {
    final filteredList = _filteredCctvList;
    
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.6),
            ),
            SizedBox(height: 16),
            Text(
              'ไม่พบกล้องที่ค้นหา',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return _buildCctvCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildCctvCard(CctvCamera cctv) {
    Color statusColor;
    IconData statusIcon;
    
    switch (cctv.status) {
      case 'ออนไลน์':
        statusColor = Colors.green;
        statusIcon = Icons.circle;
        break;
      case 'ออฟไลน์':
        statusColor = Colors.red;
        statusIcon = Icons.circle;
        break;
      case 'บำรุงรักษา':
        statusColor = Colors.orange;
        statusIcon = Icons.circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF8B4A9F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.videocam,
                  color: Color(0xFF8B4A9F),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cctv.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cctv.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cctv.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                statusIcon,
                size: 12,
                color: statusColor,
              ),
              SizedBox(width: 8),
              Text(
                cctv.status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
              Spacer(),
              Text(
                'อัปเดตล่าสุด: ${cctv.lastUpdate}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: cctv.status == 'ออนไลน์' ? () {
                    // Handle view live feed
                    _showLiveFeed(cctv);
                  } : null,
                  icon: Icon(Icons.play_arrow, size: 18),
                  label: Text('ดูสด'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4A9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle view details
                    _showCctvDetails(cctv);
                  },
                  icon: Icon(Icons.info_outline, size: 18),
                  label: Text('รายละเอียด'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF8B4A9F),
                    side: BorderSide(color: Color(0xFF8B4A9F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLiveFeed(CctvCamera cctv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ดูสดกล้อง ${cctv.name}'),
          content: Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    size: 64,
                    color: Color(0xFF8B4A9F),
                  ),
                  SizedBox(height: 16),
                  Text('กำลังเชื่อมต่อกล้อง...'),
                  SizedBox(height: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4A9F)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _showCctvDetails(CctvCamera cctv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดกล้อง'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('รหัส:', cctv.id),
              _buildDetailRow('ชื่อ:', cctv.name),
              _buildDetailRow('สถานที่:', cctv.location),
              _buildDetailRow('สถานะ:', cctv.status),
              _buildDetailRow('ประเภท:', cctv.type),
              _buildDetailRow('อัปเดตล่าสุด:', cctv.lastUpdate),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class CctvCamera {
  final String id;
  final String name;
  final String location;
  final String status;
  final String lastUpdate;
  final String type;

  CctvCamera({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.lastUpdate,
    required this.type,
  });
}