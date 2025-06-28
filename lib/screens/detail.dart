import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComplaintDetailPage extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailPage({Key? key, required this.complaint})
    : super(key: key);

  @override
  _ComplaintDetailPageState createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
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
            colors: [Color(0xFF8B4A9F), Color(0xFFD577A7), Color(0xFFF5C4C4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * -100),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Navigation and Actions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'รายละเอียดเรื่องร้องเรียน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          switch (value) {
                            case 'share':
                              _shareComplaint();
                              break;
                            case 'copy':
                              _copyComplaintNumber();
                              break;
                            case 'edit':
                              _editComplaint();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, color: Color(0xFF8B4A9F)),
                                SizedBox(width: 10),
                                Text('แชร์'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                Icon(Icons.copy, color: Color(0xFF8B4A9F)),
                                SizedBox(width: 10),
                                Text('คัดลอกเลขที่เรื่อง'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Color(0xFF8B4A9F)),
                                SizedBox(width: 10),
                                Text('แก้ไข'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Complaint Number and Status
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'เลขที่เรื่อง',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '#${widget.complaint['ComplaintNumber']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(
                              widget.complaint['ComplaintStatus'],
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Ticket: ${widget.complaint['ticket_follow']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabItem('รายละเอียด', Icons.info, 0),
          _buildTabItem('ตำแหน่ง', Icons.location_on, 1),
          _buildTabItem('ประวัติ', Icons.history, 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFF8B4A9F) : Colors.white,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Color(0xFF8B4A9F) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      margin: EdgeInsets.all(20),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        children: [_buildDetailsTab(), _buildLocationTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Basic Information Card
          _buildInfoCard('ข้อมูลพื้นฐาน', Icons.assignment, [
            _buildInfoRow(
              'ประเภทเรื่องร้องเรียน',
              widget.complaint['ComplaintTypeName'],
              Icons.category,
            ),
            _buildInfoRow(
              'วันที่แจ้ง',
              _formatDate(widget.complaint['ComplaintDate']),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'สถานะ',
              widget.complaint['ComplaintStatus'],
              Icons.flag,
            ),
          ]),

          SizedBox(height: 15),

          // Description Card
          _buildInfoCard('รายละเอียด', Icons.description, [
            _buildDescriptionSection(
              'หมายเหตุ',
              widget.complaint['ComplaintNote'],
            ),
          ]),

          SizedBox(height: 15),

          // Location Information Card
          _buildInfoCard('ข้อมูลสถานที่', Icons.location_on, [
            _buildInfoRow(
              'สถานที่',
              widget.complaint['ComplaintPlace'],
              Icons.place,
            ),
            if (widget.complaint['ComplaintStreetAlley'].isNotEmpty)
              _buildInfoRow(
                'ถนน/ซอย',
                widget.complaint['ComplaintStreetAlley'],
                Icons.rocket,
              ),
            _buildInfoRow(
              'พิกัด',
              '${widget.complaint['ComplaintLat']}, ${widget.complaint['ComplaintLong']}',
              Icons.gps_fixed,
            ),
          ]),

          SizedBox(height: 15),

          // Images Card
          _buildImagesCard(widget.complaint['ComplaintImage']),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Map placeholder
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 80,
                      color: Color(0xFF8B4A9F).withOpacity(0.5),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'แผนที่แสดงตำแหน่ง',
                      style: TextStyle(
                        color: Color(0xFF8B4A9F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Lat: ${widget.complaint['ComplaintLat']}\nLng: ${widget.complaint['ComplaintLong']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Location details
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียดตำแหน่ง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4A9F),
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildLocationDetailRow(
                    'สถานที่',
                    widget.complaint['ComplaintPlace'],
                  ),
                  if (widget.complaint['ComplaintStreetAlley'].isNotEmpty)
                    _buildLocationDetailRow(
                      'ถนน/ซอย',
                      widget.complaint['ComplaintStreetAlley'],
                    ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {

                          },
                          icon: Icon(Icons.directions),
                          label: Text('เปิดในแผนที่'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B4A9F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyCoordinates(),
                          icon: Icon(Icons.copy),
                          label: Text('คัดลอกพิกัด'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF8B4A9F),
                            side: BorderSide(color: Color(0xFF8B4A9F)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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

  Widget _buildHistoryTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ประวัติการดำเนินการ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4A9F),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                _buildTimelineItem(
                  'เรื่องร้องเรียนถูกสร้าง',
                  _formatDate(widget.complaint['ComplaintDate']),
                  Icons.add_circle,
                  Colors.blue,
                  true,
                ),
                _buildTimelineItem(
                  'ได้รับเรื่องร้องเรียนแล้ว',
                  _getRandomDate(1),
                  Icons.check_circle,
                  Colors.green,
                  widget.complaint['ComplaintStatus'] != 'รอดำเนินการ',
                ),
                _buildTimelineItem(
                  'เจ้าหน้าที่ออกตรวจสอบ',
                  _getRandomDate(2),
                  Icons.search,
                  Colors.orange,
                  widget.complaint['ComplaintStatus'] == 'เสร็จสิ้น',
                ),
                _buildTimelineItem(
                  'ดำเนินการแก้ไขเสร็จสิ้น',
                  _getRandomDate(3),
                  Icons.done_all,
                  Colors.purple,
                  widget.complaint['ComplaintStatus'] == 'เสร็จสิ้น',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF8B4A9F), size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4A9F),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 18),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String label, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes, color: Colors.grey.shade600, size: 18),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            description.isNotEmpty ? description : 'ไม่มีรายละเอียดเพิ่มเติม',
            style: TextStyle(
              color: description.isNotEmpty
                  ? Colors.black87
                  : Colors.grey.shade500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesCard(String url) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: Color(0xFF8B4A9F), size: 24),
              SizedBox(width: 10),
              Text(
                'รูปภาพ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4A9F),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          // Image placeholders
          Row(
            children: [
              Expanded(
                child: _buildImagePlaceholder(
                  'รูปภาพผู้แจ้ง',
                  Icons.camera_alt,
                  url,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildImagePlaceholder(
                  'รูปภาพเจ้าหน้าที่',
                  Icons.work,
                  url,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(
    String title,
    IconData icon, [
    String url = '',
  ]) {
    var _error = [
      Icon(icon, color: Colors.grey.shade400, size: 40),
      SizedBox(height: 8),
      Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ];

    // The Image.network widget, wrapped in a list
    var image = [
      Image.network(
        url, // Replace with your image URL
        width: 110.0, // Optional: Set image width
        height: 110.0, // Optional: Set image height
        fit: BoxFit.cover, // Optional: How to fit the image
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child; // If image loaded successfully
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _error,
          );
        },
      ),
    ];

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: url.isNotEmpty ? image : _error,
      ),
    );
  }

  Widget _buildLocationDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String date,
    IconData icon,
    Color color,
    bool isCompleted,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'รอดำเนินการ':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'อยู่ระหว่างดำเนินการ':
        color = Colors.blue;
        icon = Icons.work;
        break;
      case 'เสร็จสิ้น':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  String _getRandomDate(int daysAdd) {
    try {
      final baseDate = DateTime.parse(widget.complaint['ComplaintDate']);
      final newDate = baseDate.add(Duration(days: daysAdd));
      final day = newDate.day.toString().padLeft(2, '0');
      final month = newDate.month.toString().padLeft(2, '0');
      final year = newDate.year.toString();
      final hour = newDate.hour.toString().padLeft(2, '0');
      final minute = newDate.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '-';
    }
  }

  void _shareComplaint() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'แชร์เรื่องร้องเรียน #${widget.complaint['ComplaintNumber']}',
        ),
        backgroundColor: Color(0xFF8B4A9F),
      ),
    );
  }

  void _copyComplaintNumber() {
    Clipboard.setData(ClipboardData(text: widget.complaint['ComplaintNumber']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอกเลขที่เรื่องเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editComplaint() {
    // Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิดหน้าแก้ไขเรื่องร้องเรียน'),
        backgroundColor: Color(0xFF8B4A9F),
      ),
    );
  }

  void _copyCoordinates() {
    final coordinates =
        '${widget.complaint['ComplaintLat']}, ${widget.complaint['ComplaintLong']}';
    Clipboard.setData(ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอกพิกัดเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
