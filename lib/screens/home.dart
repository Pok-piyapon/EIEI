import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import '../services/storage.dart';
import 'dart:async';

class MunicipalHomePage extends StatefulWidget {
  @override
  _MunicipalHomePageState createState() => _MunicipalHomePageState();
}

class _MunicipalHomePageState extends State<MunicipalHomePage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isMenuOpen = false;
  String _userName = 'ผู้ใช้งาน';
  String _userProfileUrl = '';
  
  // Carousel variables
  late PageController _pageController;
  Timer? _autoSlideTimer;
  List<Map<String, dynamic>> newsItems = [
    {
      'title': 'วันแม่ แห่งชาติ ประจำปี 2567',
      'date': 'วันอาทิตย์ที่ 12 สิงหาคม 2567 เวลา 07.30 น.',
      'info': 'ข่าวสาร/กิจกรรม',
      'icon': Icons.event,
    },
    {
      'title': 'กิจกรรมชุมชนเทศบาล',
      'date': 'วันจันทร์ที่ 15 สิงหาคม 2567 เวลา 10.00 น.',
      'info': 'กิจกรรม',
      'icon': Icons.group,
    },
    {
      'title': 'การประชุมสภาเทศบาล',
      'date': 'วันพุธที่ 20 สิงหาคม 2567 เวลา 14.00 น.',
      'info': 'ประชุม',
      'icon': Icons.meeting_room,
    },
    {
      'title': 'เทศกาลอาหารท้องถิ่น',
      'date': 'วันศุกร์ที่ 25 สิงหาคม 2567 เวลา 18.00 น.',
      'info': 'เทศกาล',
      'icon': Icons.food_bank,
    },
    {
      'title': 'การพัฒนาพื้นที่สีเขียว',
      'date': 'วันอังคารที่ 30 สิงหาคม 2567 เวลา 09.00 น.',
      'info': 'การพัฒนา',
      'icon': Icons.nature,
    },
    {
      'title': 'ให้บริการทำความสะอาด',
      'date': 'วันอาทิตย์ที่ 2 กันยายน 2567 เวลา 08.00 น.',
      'info': 'บริการ',
      'icon': Icons.cleaning_services,
    },
    {
      'title': 'โครงการตรวจสุขภาพประชาชน',
      'date': 'วันพุธที่ 5 กันยายน 2567 เวลา 13.00 น.',
      'info': 'ตรวจสุขภาพ',
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'โครงการประกวดรางวัลดิเด็กดี',
      'date': 'วันศุกร์ที่ 10 กันยายน 2567 เวลา 16.00 น.',
      'info': 'ประกวด',
      'icon': Icons.emoji_events,
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize carousel
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
    
    _loadUserName();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
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
                  // Header
                  _buildHeader(context),

                  // Notification Card
                  _buildNotificationCard(),

                  // Action Buttons
                  _buildActionButtons(context),

                  // Feature Grid
                  Expanded(child: _buildFeatureGrid()),
                ],
              ),
            ),
          ),

          // Overlay when menu is open
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Side Menu
          SlideTransition(
            position: _slideAnimation,
            child: _buildSideMenu(context),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserName() async {
    try {
      final firstName = await AuthStorage.get('user_firstname');
      final lastName = await AuthStorage.get('user_lastname');
      setState(() {
        _userName = firstName != null && lastName != null
            ? '$firstName $lastName'
            : 'ผู้ใช้งาน';
      });
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients && newsItems.isNotEmpty) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= newsItems.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }


  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Animated Burger Menu
          GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isMenuOpen
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _slideController,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'เทศบาล',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderIconButton(Icons.notifications, () {
            context.go("/mailbox");
          }),
          SizedBox(width: 8),
          _buildHeaderIconButton(Icons.person, () {
            context.go("/profile");
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Menu Header
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF8B4A9F),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'สวัสดี',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            _userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuItem(Icons.home, 'หน้าหลัก', () {
                  _toggleMenu();
                  context.go('/');
                }),
                _buildMenuItem(Icons.article, 'ข่าวสาร', () {
                  _toggleMenu();
                  context.go('/news');
                }),
                _buildMenuItem(Icons.slideshow, 'บทความ', () {
                  _toggleMenu();
                  context.go('/blog');
                }),
                _buildMenuItem(Icons.campaign, 'ร้องเรียน', () {
                  _toggleMenu();
                  context.go('/complain');
                }),
                _buildMenuItem(Icons.videocam, 'CCTV', () {
                  _toggleMenu();
                  context.go('/cctv');
                }),
                _buildMenuItem(Icons.emoji_events, 'รางวัลที่ได้รับ', () {
                  _toggleMenu();
                  context.go('/award');
                }),
                _buildMenuItem(Icons.tour, 'ท่องเที่ยว', () {
                  _toggleMenu();
                  context.go('/tourism');
                }),
                _buildMenuItem(Icons.store, 'สินค้า OTOP', () {
                  _toggleMenu();
                  context.go('/otop');
                }),
                Divider(color: Colors.grey.shade300),
                _buildMenuItem(Icons.person, 'ตั้งค่า', () {
                  _toggleMenu();
                  context.go('/profile');
                }),
                _buildMenuItem(Icons.logout, 'ออกจากระบบ', () {
                  _toggleMenu();
                  context.go('/login');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Color(0xFF8B4A9F), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildNotificationCard() {

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Handle notification tap
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
                          ),
                        ),
                        child: Icon(
                          newsItems[index]['icon'] as IconData,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItems[index]['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              newsItems[index]['date']!,
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD7BBE6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    newsItems[index]['info']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF8B4A9F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '12 ส.ค. 2024',
                                  style: TextStyle(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4A9F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'อ่านต่อ',
                          style: TextStyle(
                            color: Color(0xFF8B4A9F),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF8B4A9F), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.list_alt,
                'รายการ',
                '/list',
                Color(0xFF8B4A9F),
              ),
              _buildActionButton(
                context,
                Icons.campaign,
                'ร้องเรียน',
                '/complain',
                Color(0xFF8B4A9F),
              ),
              _buildActionButton(
                context,
                Icons.phone,
                'สายด่วน',
                '/express_call',
                Color(0xFF8B4A9F),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    String router,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(router),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B4A9F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.article_outlined, 'label': 'ข่าวสาร', 'router': '/news', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.slideshow_outlined, 'label': 'บทความ', 'router': '/blog', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.videocam_outlined, 'label': 'CCTV', 'router': '/cctv', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.emoji_events_outlined, 'label': 'รางวัล', 'router': '/award', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.play_circle_outline, 'label': 'Youtube', 'router': '/', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.help_outline, 'label': 'ช่วยเหลือ', 'router': '/', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.tour_outlined, 'label': 'ท่องเที่ยว', 'router': '/', 'color': Color(0xFF8B4A9F)},
      {'icon': Icons.store_outlined, 'label': 'สินค้า OTOP', 'router': '/', 'color': Color(0xFF8B4A9F)},
    ];

    return Container(
      margin: EdgeInsets.all(16),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureItem(
            feature['icon'] as IconData,
            feature['label'] as String,
            feature['router'] as String,
            feature['color'] as Color,
            context,
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String label,
    String router,
    Color color,
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(router),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF8B4A9F), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B4A9F),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}