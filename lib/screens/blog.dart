import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MunicipalBlogPage extends StatefulWidget {
  @override
  _MunicipalBlogPageState createState() => _MunicipalBlogPageState();
}

class _MunicipalBlogPageState extends State<MunicipalBlogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'ทั้งหมด';

  // Sample blog data
  final List<BlogPost> _blogList = [
    BlogPost(
      id: '001',
      title: 'เทคนิคการพัฒนาเว็บแอปพลิเคชัน',
      author: 'นายเดือน สว่าง',
      category: 'เทคโนโลยี',
      date: '2025-07-07',
      readTime: '5 นาที',
      views: 1250,
      likes: 45,
      comments: 12,
      tags: ['Web Development', 'Programming', 'Technology'],
      summary: 'บทความเกี่ยวกับเทคนิคการพัฒนาเว็บแอปพลิเคชันสมัยใหม่',
      status: 'เผยแพร่แล้ว',
    ),
    BlogPost(
      id: '002',
      title: 'การจัดการฐานข้อมูลอย่างมีประสิทธิภาพ',
      author: 'นางสาววดี แก้ว',
      category: 'ฐานข้อมูล',
      date: '2025-07-06',
      readTime: '8 นาที',
      views: 890,
      likes: 32,
      comments: 8,
      tags: ['Database', 'SQL', 'Performance'],
      summary: 'คู่มือการปรับปรุงประสิทธิภาพฐานข้อมูล',
      status: 'เผยแพร่แล้ว',
    ),
    BlogPost(
      id: '003',
      title: 'UI/UX Design Trends 2025',
      author: 'นายโสม ใหม่',
      category: 'ออกแบบ',
      date: '2025-07-05',
      readTime: '6 นาที',
      views: 1420,
      likes: 67,
      comments: 15,
      tags: ['Design', 'UI', 'UX', 'Trends'],
      summary: 'แนวโน้มการออกแบบ UI/UX ที่น่าสนใจในปี 2025',
      status: 'เผยแพร่แล้ว',
    ),
    BlogPost(
      id: '004',
      title: 'การเรียนรู้ Machine Learning เบื้องต้น',
      author: 'นายดาว ดี',
      category: 'ปัญญาประดิษฐ์',
      date: '2025-07-04',
      readTime: '10 นาที',
      views: 750,
      likes: 28,
      comments: 6,
      tags: ['Machine Learning', 'AI', 'Data Science'],
      summary: 'บทความแนะนำการเรียนรู้ Machine Learning สำหรับผู้เริ่มต้น',
      status: 'ร่าง',
    ),
    BlogPost(
      id: '005',
      title: 'Mobile App Development with Flutter',
      author: 'นางสาวดี โค้ด',
      category: 'มือถือ',
      date: '2025-07-03',
      readTime: '7 นาที',
      views: 1100,
      likes: 52,
      comments: 10,
      tags: ['Flutter', 'Mobile', 'Development'],
      summary: 'การพัฒนาแอปพลิเคชันมือถือด้วย Flutter',
      status: 'เผยแพร่แล้ว',
    ),
    BlogPost(
      id: '006',
      title: 'Cloud Computing และการประยุกต์ใช้',
      author: 'นายคลาวด์ เทค',
      category: 'คลาวด์',
      date: '2025-07-02',
      readTime: '9 นาที',
      views: 680,
      likes: 25,
      comments: 4,
      tags: ['Cloud', 'AWS', 'Azure', 'Infrastructure'],
      summary: 'ภาพรวมของ Cloud Computing และการใช้งานจริง',
      status: 'รอตรวจสอบ',
    ),
  ];

  List<BlogPost> get _filteredBlogList {
    List<BlogPost> filtered = _blogList;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((blog) =>
          blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    // Filter by category
    if (_selectedFilter != 'ทั้งหมด') {
      filtered = filtered.where((blog) => blog.category == _selectedFilter).toList();
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
              _buildBlogSummary(),
              Expanded(child: _buildBlogList()),
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
            Icons.book,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(
            'บล็อก',
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
              hintText: 'ค้นหาบล็อก...',
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
                _buildFilterChip('เทคโนโลยี'),
                SizedBox(width: 8),
                _buildFilterChip('ฐานข้อมูล'),
                SizedBox(width: 8),
                _buildFilterChip('ออกแบบ'),
                SizedBox(width: 8),
                _buildFilterChip('ปัญญาประดิษฐ์'),
                SizedBox(width: 8),
                _buildFilterChip('มือถือ'),
                SizedBox(width: 8),
                _buildFilterChip('คลาวด์'),
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

  Widget _buildBlogSummary() {
    final totalBlogs = _blogList.length;
    final publishedBlogs = _blogList.where((b) => b.status == 'เผยแพร่แล้ว').length;
    final totalViews = _blogList.fold(0, (sum, blog) => sum + blog.views);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'บล็อกทั้งหมด',
              totalBlogs.toString(),
              Colors.blue,
              Icons.book,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'เผยแพร่แล้ว',
              publishedBlogs.toString(),
              Colors.green,
              Icons.publish,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ยอดอ่าน',
              _formatViews(totalViews),
              Colors.orange,
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

  Widget _buildBlogList() {
    final filteredList = _filteredBlogList;
    
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
              'ไม่พบบล็อกที่ค้นหา',
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
          return _buildBlogCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildBlogCard(BlogPost blog) {
    Color categoryColor = _getCategoryColor(blog.category);
    Color statusColor = _getStatusColor(blog.status);

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
          // Blog Header with gradient background
          Container(
            height: 120,
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
                    Icons.article,
                    size: 48,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                // ID Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${blog.id}',
                      style: TextStyle(
                        color: Color(0xFF8B4A9F),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      blog.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      blog.category,
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
          
          // Blog Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  blog.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 12),
                
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: blog.tags.take(3).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B4A9F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF8B4A9F).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B4A9F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                SizedBox(height: 16),
                
                // Author and Date info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      blog.author,
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
                      blog.readTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Stats Row
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatViews(blog.views),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      blog.likes.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.comment,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      blog.comments.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    Text(
                      blog.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Action Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showBlogDetail(blog);
                        },
                        icon: Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'อ่านต่อ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B4A9F),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
      case 'เทคโนโลยี':
        return Colors.blue;
      case 'ฐานข้อมูล':
        return Colors.green;
      case 'ออกแบบ':
        return Colors.purple;
      case 'ปัญญาประดิษฐ์':
        return Colors.orange;
      case 'มือถือ':
        return Colors.teal;
      case 'คลาวด์':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'เผยแพร่แล้ว':
        return Colors.green;
      case 'ร่าง':
        return Colors.orange;
      case 'รอตรวจสอบ':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showBlogDetail(BlogPost blog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            blog.title,
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(blog.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blog.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(blog.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blog.status,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  blog.summary,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'แท็ก: ${blog.tags.join(', ')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(blog.author, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Spacer(),
                    Text(blog.date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${_formatViews(blog.views)} ยอดอ่าน', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 16),
                    Icon(Icons.favorite, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${blog.likes} ไลค์', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 16),
                    Icon(Icons.comment, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${blog.comments} ความคิดเห็น', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('แชร์บล็อกสำเร็จ')),
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

class BlogPost {
  final String id;
  final String title;
  final String author;
  final String category;
  final String date;
  final String readTime;
  final int views;
  final int likes;
  final int comments;
  final List<String> tags;
  final String summary;
  final String status;

  BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.date,
    required this.readTime,
    required this.views,
    required this.likes,
    required this.comments,
    required this.tags,
    required this.summary,
    required this.status,
  });
}
