import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MunicipalNewsPage extends StatefulWidget {
  @override
  _MunicipalNewsPageState createState() => _MunicipalNewsPageState();
}

class _MunicipalNewsPageState extends State<MunicipalNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'ทั้งหมด';

  // Sample news data
  final List<NewsArticle> _newsList = [
    NewsArticle(
      id: '001',
      title: 'เทศบาลจัดงานเทศกาลดนตรีประจำปี 2025',
      summary: 'เทศบาลจัดงานเทศกาลดนตรีใหญ่ที่สวนสาธารณะ พร้อมศิลปินชื่อดังมาร่วมแสดง',
      category: 'กิจกรรม',
      date: '29 มิ.ย. 2025',
      author: 'ฝ่ายประชาสัมพันธ์',
      imageUrl: 'assets/images/news1.jpg',
      readTime: '3 นาที',
      isImportant: true,
      views: 1250,
    ),
    NewsArticle(
      id: '002',
      title: 'ประกาศปิดซ่อมถนนสายหลัก วันที่ 30 มิถุนายน',
      summary: 'เทศบาลจะทำการซ่อมแซมถนนสายหลัก ขอความร่วมมือประชาชนใช้เส้นทางอื่น',
      category: 'ประกาศ',
      date: '28 มิ.ย. 2025',
      author: 'กองช่าง',
      imageUrl: 'assets/images/news2.jpg',
      readTime: '2 นาที',
      isImportant: true,
      views: 890,
    ),
    NewsArticle(
      id: '003',
      title: 'โครงการปลูกต้นไม้เพื่อสิ่งแวดล้อม',
      summary: 'เทศบาลเปิดรับสมัครประชาชนร่วมปลูกต้นไม้ในพื้นที่สาธารณะ',
      category: 'สิ่งแวดล้อม',
      date: '27 มิ.ย. 2025',
      author: 'กองสาธารณสุข',
      imageUrl: 'assets/images/news3.jpg',
      readTime: '4 นาที',
      isImportant: false,
      views: 654,
    ),
    NewsArticle(
      id: '004',
      title: 'เปิดให้บริการศูนย์กีฬาใหม่',
      summary: 'ศูนย์กีฬาครบครันแห่งใหม่พร้อมให้บริการประชาชนแล้ว',
      category: 'กิจกรรม',
      date: '26 มิ.ย. 2025',
      author: 'กองการศึกษา',
      imageUrl: 'assets/images/news4.jpg',
      readTime: '5 นาที',
      isImportant: false,
      views: 432,
    ),
    NewsArticle(
      id: '005',
      title: 'แจ้งตารางจ่ายน้ำประปาประจำสัปดาห์',
      summary: 'ตารางการจ่ายน้ำประปาในพื้นที่ต่างๆ ประจำสัปดาห์นี้',
      category: 'ประกาศ',
      date: '25 มิ.ย. 2025',
      author: 'กองสาธารณูปโภค',
      imageUrl: 'assets/images/news5.jpg',
      readTime: '2 นาที',
      isImportant: false,
      views: 1100,
    ),
    NewsArticle(
      id: '006',
      title: 'การประชุมประชาคมเพื่อพัฒนาเมือง',
      summary: 'เชิญประชาชนร่วมประชุมเพื่อหารือแผนพัฒนาเมืองในอนาคต',
      category: 'ประชุม',
      date: '24 มิ.ย. 2025',
      author: 'สำนักปลัด',
      imageUrl: 'assets/images/news6.jpg',
      readTime: '6 นาที',
      isImportant: false,
      views: 780,
    ),
  ];

  List<NewsArticle> get _filteredNewsList {
    List<NewsArticle> filtered = _newsList;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((news) =>
          news.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by category
    if (_selectedFilter != 'ทั้งหมด') {
      filtered = filtered.where((news) => news.category == _selectedFilter).toList();
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
              _buildNewsSummary(),
              Expanded(child: _buildNewsList()),
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
            Icons.article,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'ข่าวสาร',
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
              hintText: 'ค้นหาข่าวสาร...',
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
                _buildFilterChip('ประกาศ'),
                SizedBox(width: 8),
                _buildFilterChip('กิจกรรม'),
                SizedBox(width: 8),
                _buildFilterChip('สิ่งแวดล้อม'),
                SizedBox(width: 8),
                _buildFilterChip('ประชุม'),
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

  Widget _buildNewsSummary() {
    final totalNews = _newsList.length;
    final importantNews = _newsList.where((n) => n.isImportant).length;
    final totalViews = _newsList.fold(0, (sum, news) => sum + news.views);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'ข่าวทั้งหมด',
              totalNews.toString(),
              Colors.blue,
              Icons.article,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ข่าวสำคัญ',
              importantNews.toString(),
              Colors.red,
              Icons.priority_high,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ยอดอ่าน',
              _formatViews(totalViews),
              Colors.green,
              Icons.visibility,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  Widget _buildNewsList() {
    final filteredList = _filteredNewsList;
    
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
              'ไม่พบข่าวสารที่ค้นหา',
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
          return _buildNewsCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle news) {
    Color categoryColor = _getCategoryColor(news.category);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          // News Image Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B4A9F).withOpacity(0.8),
                  Color(0xFFD577A7).withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                if (news.isImportant)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'สำคัญ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      news.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // News Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  news.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      news.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      news.readTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatViews(news.views),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                Row(
                  children: [
                    Text(
                      news.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        _showNewsDetail(news);
                      },
                      child: Text(
                        'อ่านต่อ',
                        style: TextStyle(
                          color: Color(0xFF8B4A9F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ประกาศ':
        return Colors.orange;
      case 'กิจกรรม':
        return Colors.blue;
      case 'สิ่งแวดล้อม':
        return Colors.green;
      case 'ประชุม':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showNewsDetail(NewsArticle news) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            news.title,
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(news.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    news.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  news.summary,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'เนื้อหาข่าวแบบเต็ม...\n\nนี่คือตัวอย่างเนื้อหาข่าวที่จะแสดงรายละเอียดเต็มของข่าวสาร เมื่อผู้ใช้คลิกอ่านต่อ จะได้เห็นข่าวสารอย่างครบถ้วน',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(news.author, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Spacer(),
                    Text(news.date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Handle share
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('แชร์ข่าวสำเร็จ')),
                    );
                  },
                  icon: Icon(Icons.share, size: 16),
                  label: Text('แชร์'),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('ปิด'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String date;
  final String author;
  final String imageUrl;
  final String readTime;
  final bool isImportant;
  final int views;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.date,
    required this.author,
    required this.imageUrl,
    required this.readTime,
    required this.isImportant,
    required this.views,
  });
}