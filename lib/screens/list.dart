import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api.dart';
import 'package:dio/dio.dart';
import '../screens/detail.dart';
import 'map_screen.dart';

Future<List<Map<String, dynamic>>> Request() async {
  var api = ApiExternal.getDioInstance();
  Response res = await api.get('/complain?Department=11');

  // Parsing the response to map the data into the required structure
  List<dynamic> results =
      res.data['Results']; // Assuming 'Results' contains a list of complaints
  List<Map<String, dynamic>> allComplaints = results.map((complaint) {
    return {
      "ComplaintNumber": complaint["ComplaintNumber"] ?? "",
      "ticket_follow": complaint["ticket_follow"] ?? "",
      "ComplaintNote": complaint["ComplaintNote"] ?? "",
      "ComplaintTypeName": complaint["ComplaintTypeName"] ?? "",
      "ComplaintPlace": complaint["ComplaintPlace"] ?? "",
      "ComplaintStreetAlley": complaint["ComplaintStreetAlley"] ?? "",
      "ComplaintLat": complaint["ComplaintLat"] ?? "",
      "ComplaintLong": complaint["ComplaintLong"] ?? "",
      "ComplaintImage": complaint["ComplaintImage"] ?? "",
      "ComplaintImageOfficer": complaint["ComplaintImageOfficer"] ?? "",
      "ComplaintStatus": complaint["ComplaintStatus"] ?? "",
      "ComplaintDate": complaint["ComplaintDate"] ?? "",
    };
  }).toList();

  return allComplaints;
}

class ComplaintsListPage extends StatefulWidget {
  @override
  _ComplaintsListPageState createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends State<ComplaintsListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allComplaints = [];
  List<Map<String, dynamic>> filteredComplaints = [];
  String selectedStatus = 'ทั้งหมด';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _loadComplaints();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadComplaints() {
    Future<void> _loadComplaints() async {
      try {
        List<Map<String, dynamic>> complaints = await Request();
        setState(() {
          allComplaints = complaints;
          filteredComplaints = List.from(allComplaints);
        });
      } catch (e) {
        print("Error loading complaints: $e");
      }
    }

    _loadComplaints();
    filteredComplaints = List.from(allComplaints); // line 143
  }

  void _filterComplaints() {
    setState(() {
      filteredComplaints = allComplaints.where((complaint) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch =
            searchText.isEmpty ||
            complaint['ComplaintNumber'].toString().toLowerCase().contains(
              searchText,
            ) ||
            complaint['ComplaintNote'].toString().toLowerCase().contains(
              searchText,
            ) ||
            complaint['ComplaintTypeName'].toString().toLowerCase().contains(
              searchText,
            ) ||
            complaint['ComplaintPlace'].toString().toLowerCase().contains(
              searchText,
            ) ||
            complaint['ticket_follow'].toString().toLowerCase().contains(
              searchText,
            );

        final matchesStatus =
            selectedStatus == 'ทั้งหมด' ||
            complaint['ComplaintStatus'] == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchAndFilter(),
                _buildStatsCards(),
                Expanded(child: _buildComplaintsList()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/complain');
        },
        backgroundColor: Color(0xFF8B4A9F),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'เพิ่มเรื่องร้องเรียน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.assignment, color: Colors.white, size: 28),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เรื่องร้องเรียน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ระบบจัดการเรื่องร้องเรียน',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Icon(
              Icons.home,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) => _filterComplaints(),
            decoration: InputDecoration(
              hintText: 'ค้นหาเลขที่เรื่อง, หมายเหตุ, ประเภท...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF8B4A9F)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Color(0xFF8B4A9F)),
                      onPressed: () {
                        _searchController.clear();
                        _filterComplaints();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color(0xFF8B4A9F), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),

          SizedBox(height: 15),

          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'ทั้งหมด',
                    'รอดำเนินการ',
                    'อยู่ระหว่างดำเนินการ',
                    'เสร็จสิ้น',
                  ].map((status) {
                    final isSelected = selectedStatus == status;
                    return Container(
                      margin: EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(
                          status,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Color(0xFF8B4A9F),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedStatus = status;
                          });
                          _filterComplaints();
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Color(0xFF8B4A9F),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalComplaints = allComplaints.length;
    final pendingComplaints = allComplaints
        .where((c) => c['ComplaintStatus'] == 'รอดำเนินการ')
        .length;
    final inProgressComplaints = allComplaints
        .where((c) => c['ComplaintStatus'] == 'อยู่ระหว่างดำเนินการ')
        .length;
    final completedComplaints = allComplaints
        .where((c) => c['ComplaintStatus'] == 'เสร็จสิ้น')
        .length;

    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'ทั้งหมด',
              totalComplaints.toString(),
              Icons.assignment,
              Colors.blue,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'รอดำเนินการ',
              pendingComplaints.toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'ดำเนินการ',
              inProgressComplaints.toString(),
              Icons.work,
              Colors.purple,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'เสร็จสิ้น',
              completedComplaints.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
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
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: filteredComplaints.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = filteredComplaints[index];
                return _buildComplaintCard(complaint, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          SizedBox(height: 20),
          Text(
            'ไม่พบเรื่องร้องเรียน',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOutBack,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4A9F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF8B4A9F).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '#${complaint['ComplaintNumber']}',
                          style: TextStyle(
                            color: Color(0xFF8B4A9F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Spacer(),
                      _buildStatusBadge(complaint['ComplaintStatus']),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Type
                  Row(
                    children: [
                      Icon(Icons.category, color: Color(0xFF8B4A9F), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint['ComplaintTypeName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Note
                  if (complaint['ComplaintNote'].isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, color: Colors.grey.shade600, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            complaint['ComplaintNote'],
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 10),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red.shade400,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${complaint['ComplaintPlace']}${complaint['ComplaintStreetAlley'].isNotEmpty ? ', ${complaint['ComplaintStreetAlley']}' : ''}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        _formatDate(complaint['ComplaintDate']),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Ticket: ${complaint['ticket_follow']}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _openMap(complaint);
                          },
                          icon: Icon(Icons.map, size: 16),
                          label: Text('แผนที่', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF8B4A9F),
                            side: BorderSide(color: Color(0xFF8B4A9F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ComplaintDetailPage(
                                  complaint: filteredComplaints[index],
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility, size: 16),
                          label: Text(
                            'รายละเอียด',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B4A9F),
                            foregroundColor: Colors.white,
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
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
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

  void _openMap(Map<String, dynamic> complaint) {
    // Check if the complaint has valid coordinates
    final lat = double.tryParse(complaint['ComplaintLat'].toString()) ?? 0.0;
    final lng = double.tryParse(complaint['ComplaintLong'].toString()) ?? 0.0;
    
    if (lat == 0.0 && lng == 0.0) {
      // Show error message if no coordinates available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่พบข้อมูลตำแหน่งสำหรับเรื่องร้องเรียนนี้'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Navigate to MapScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          complaint: complaint,
          allComplaints: allComplaints, // Pass all complaints for "show all" feature
        ),
      ),
    );
  }
}
