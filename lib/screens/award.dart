import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AwardsShowcasePage extends StatefulWidget {
  @override
  _AwardsShowcasePageState createState() => _AwardsShowcasePageState();
}

class _AwardsShowcasePageState extends State<AwardsShowcasePage>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  final List<AwardItem> _awards = [
    AwardItem(
      id: '001',
      title: 'เหรียญเชิดชูเกียรติ',
      subtitle: 'Gold Medal of Honor',
      description: 'เหรียญเกียรติยศที่มอบให้แก่บุคคลที่มีผลงานดีเด่นในการรับใช้ชุมชน',
      category: 'เกียรติยศ',
      yearReceived: 2022,
      organization: 'เทศบาลนคร',
      color: Color(0xFFFFD700),
      icon: Icons.military_tech,
      achievement: 'ผู้นำชุมชนดีเด่น',
    ),
    AwardItem(
      id: '002',
      title: 'เกียรติบัตรการปกครอง',
      subtitle: 'Certificate of Governance',
      description: 'เกียรติบัตรที่มอบให้แก่ผู้ที่ได้ทำงานบริการชุมชนอย่างดีเยี่ยม',
      category: 'เกียรติบัตร',
      yearReceived: 2021,
      organization: 'การปกครองส่วนท้องถิ่น',
      color: Color(0xFF4FC3F7),
      icon: Icons.verified,
      achievement: 'บริการสาธารณะดีเด่น',
    ),
    AwardItem(
      id: '003',
      title: 'โล่เชิดชูเกียรติ',
      subtitle: 'Shield of Excellence',
      description: 'โล่เชิดชูเกียรติสำหรับผู้ทำงานดีเด่นในด้านศิลปวัฒนธรรม',
      category: 'โล่รางวัล',
      yearReceived: 2020,
      organization: 'สภาวัฒนธรรมแห่งชาติ',
      color: Color(0xFFAB47BC),
      icon: Icons.emoji_events,
      achievement: 'อนุรักษ์วัฒนธรรมไทย',
    ),
    AwardItem(
      id: '004',
      title: 'รางวัลสิ่งแวดล้อม',
      subtitle: 'Environmental Award',
      description: 'รางวัลเพื่อการอนุรักษ์สิ่งแวดล้อมและการพัฒนาอย่างยั่งยืน',
      category: 'สิ่งแวดล้อม',
      yearReceived: 2019,
      organization: 'กรมส่งเสริมคุณภาพสิ่งแวดล้อม',
      color: Color(0xFF66BB6A),
      icon: Icons.eco,
      achievement: 'โครงการป่าชุมชน',
    ),
    AwardItem(
      id: '005',
      title: 'เหรียญอาสาสมัคร',
      subtitle: 'Volunteer Medal',
      description: 'เหรียญรางวัลสำหรับอาสาสมัครที่ทำงานเพื่อชุมชนอย่างต่อเนื่อง',
      category: 'อาสาสมัคร',
      yearReceived: 2018,
      organization: 'กระทรวงการพัฒนาสังคมและความมั่นคง',
      color: Color(0xFFFF7043),
      icon: Icons.volunteer_activism,
      achievement: 'อาสาช่วยเหลือสังคม',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
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
              _buildAwardCounter(),
              Expanded(child: _buildAwardCarousel()),
              _buildTimelineIndicator(),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Spacer(),
          Column(
            children: [
              Text(
                'รางวัลของฉัน',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'MY AWARDS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Spacer(),
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Icon(
                  Icons.stars,
                  color: Color(0xFFFFD700),
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAwardCounter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B4A9F), Color(0xFFD577A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B4A9F).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCounterItem('${_awards.length}', 'รางวัลทั้งหมด', Icons.emoji_events),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildCounterItem('${_awards.where((a) => a.yearReceived >= 2020).length}', 'ปีล่าสุด', Icons.new_releases),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildCounterItem('${_awards.where((a) => a.category == 'เกียรติยศ').length}', 'เกียรติยศ', Icons.military_tech),
        ],
      ),
    );
  }

  Widget _buildCounterItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAwardCarousel() {
    return Container(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _awards.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Transform.scale(
                scale: value,
                child: _buildAwardCard(_awards[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAwardCard(AwardItem award) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            award.color.withOpacity(0.8),
            award.color.withOpacity(0.6),
            Colors.white.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: award.color.withOpacity(0.4),
            blurRadius: 25,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -50,
            right: -50,
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_scaleController.value * 0.2),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        award.icon,
                        color: award.color,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            award.yearReceived.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            award.category,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  award.title,
                  style: TextStyle(
                  color: Color(0xFF2D1B69),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  award.subtitle,
                  style: TextStyle(
                  color: Color(0xFF2D1B69).withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  award.description,
                  style: TextStyle(
                  color: Color(0xFF2D1B69).withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 16, color: award.color),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          award.organization,
                          style: TextStyle(
                            color: award.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: award.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    award.achievement,
                    style: TextStyle(
                    color: Color(0xFF2D1B69),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_awards.length, (index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 30 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index 
                    ? _awards[index].color 
                    : Colors.white30,
                borderRadius: BorderRadius.circular(4),
                boxShadow: _currentIndex == index ? [
                  BoxShadow(
                    color: _awards[index].color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                onPressed: () => _showAwardDetails(_awards[_currentIndex]),
                icon: Icon(Icons.info_outline),
                label: Text('รายละเอียด'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _awards[_currentIndex].color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: _awards[_currentIndex].color.withOpacity(0.4),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              onPressed: () => _shareAward(_awards[_currentIndex]),
              icon: Icon(Icons.share),
              label: Text('แชร์'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _awards[_currentIndex].color,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: _awards[_currentIndex].color, width: 2),
                ),
                elevation: 3,
                shadowColor: _awards[_currentIndex].color.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAwardDetails(AwardItem award) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: award.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(award.icon, color: award.color, size: 30),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                award.title,
                                style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D1B69),
                                ),
                              ),
                              Text(
                                award.subtitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      award.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 25),
                    _buildDetailRow('หน่วยงาน', award.organization, Icons.business),
                    _buildDetailRow('ปีที่ได้รับ', award.yearReceived.toString(), Icons.calendar_today),
                    _buildDetailRow('ประเภท', award.category, Icons.category),
                    _buildDetailRow('ความสำเร็จ', award.achievement, Icons.star),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _awards[_currentIndex].color, size: 20),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1B69),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _shareAward(AwardItem award) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 10),
            Text('แชร์รางวัล "${award.title}" สำเร็จ'),
          ],
        ),
        backgroundColor: award.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class AwardItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final int yearReceived;
  final String organization;
  final Color color;
  final IconData icon;
  final String achievement;

  AwardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.yearReceived,
    required this.organization,
    required this.color,
    required this.icon,
    required this.achievement,
  });
}
