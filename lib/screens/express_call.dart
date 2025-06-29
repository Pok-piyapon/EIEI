import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class ExpressCallPage extends StatefulWidget {
  @override
  _ExpressCallPageState createState() => _ExpressCallPageState();
}

class _ExpressCallPageState extends State<ExpressCallPage> {
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  
  final List<String> _categories = [
    'ทั้งหมด',
    'ฉุกเฉิน',
    'สุขภาพ',
    'เด็กและครอบครัว',
    'การเดินทาง',
    'ภาครัฐ',
    'สาธารณูปโภค',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สายด่วนฉุกเฉิน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF8B4A9F),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/');
            }
          },
        ),
      ),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                
                // Header with icon
                _buildHeader(),
                
                SizedBox(height: 20),
                
                // Search and Filter Section
                _buildSearchAndFilter(),
                
                SizedBox(height: 20),
                
                // Filtered Sections
                ..._buildFilteredSections(),
                
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
        children: [
          Icon(
            Icons.phone_in_talk,
            color: Color(0xFF8B4A9F),
            size: 60,
          ),
          SizedBox(height: 12),
          Text(
            'สายด่วนฉุกเฉิน',
            style: TextStyle(
              color: Color(0xFF8B4A9F),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'กดเพื่อโทรหาหน่วยงานที่ต้องการ',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'ค้นหาหมายเลขหรือชื่อหน่วยงาน...',
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                bool isSelected = _selectedCategory == category;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF8B4A9F),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Color(0xFF8B4A9F),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: Color(0xFF8B4A9F),
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSections() {
    List<Widget> sections = [];
    
    // All sections data
    Map<String, Map<String, dynamic>> allSections = {
      'ฉุกเฉิน': {
        'title': '📞 สายด่วนฉุกเฉินและความปลอดภัย',
        'calls': [
          CallItem('191', 'ตํารวจ', Icons.local_police),
          CallItem('1669', 'กู้ชีพ / เหตุฉุกเฉินทางการแพทย์', Icons.local_hospital),
          CallItem('199', 'แจ้งเหตุเพลิงไหม้', Icons.local_fire_department),
          CallItem('1418', 'มูลนิธิป่อเต็กตึ๊ง', Icons.volunteer_activism),
          CallItem('1646', 'มูลนิธิร่วมกตัญญู', Icons.favorite),
        ],
      },
      'สุขภาพ': {
        'title': '🏥 สายด่วนสุขภาพและสาธารณสุข',
        'calls': [
          CallItem('1422', 'กรมควบคุมโรค (สายด่วนสุขภาพ สธ.)', Icons.medical_services),
          CallItem('1367', 'ศูนย์พิษวิทยา', Icons.warning),
          CallItem('1600', 'สายด่วนเลิกบุหรี่', Icons.smoke_free),
          CallItem('1323', 'ปรึกษาปัญหาสุขภาพจิต (กรมสุขภาพจิต)', Icons.psychology),
        ],
      },
      'เด็กและครอบครัว': {
        'title': '🧒 เด็ก สตรี ครอบครัว และสิทธิมนุษยชน',
        'calls': [
          CallItem('1300', 'ศูนย์ช่วยเหลือสังคม (หญิง-เด็ก-คนชรา)', Icons.family_restroom),
          CallItem('1387', 'สายใยครอบครัว', Icons.groups),
          CallItem('0-2412-1196', 'มูลนิธิศูนย์พิทักษ์สิทธิเด็ก', Icons.child_care),
        ],
      },
      'การเดินทาง': {
        'title': '🚗 การเดินทางและจราจร',
        'calls': [
          CallItem('1193', 'ตํารวจทางหลวง', Icons.local_police),
          CallItem('1543', 'การทางพิเศษแห่งประเทศไทย', Icons.drive_eta),
          CallItem('1690', 'การรถไฟแห่งประเทศไทย', Icons.train),
          CallItem('1348', 'ขสมก. (รถเมล์ในเขตกรุงเทพฯ)', Icons.directions_bus),
        ],
      },
      'ภาครัฐ': {
        'title': '💼 หน่วยงานบริการภาครัฐ และร้องเรียนทั่วไป',
        'calls': [
          CallItem('1548', 'กรมการปกครอง (บัตร ปชช., ทะเบียนบ้าน)', Icons.badge),
          CallItem('1205', 'ป.ป.ช. (ร้องเรียนทุจริต)', Icons.report_problem),
          CallItem('1111', 'ศูนย์บริการประชาชน (รัฐบาล)', Icons.support_agent),
          CallItem('1567', 'ศูนย์ดํารงธรรม', Icons.balance),
        ],
      },
      'สาธารณูปโภค': {
        'title': '⚡ สาธารณูปโภค',
        'calls': [
          CallItem('1129', 'การไฟฟ้านครหลวง / การไฟฟ้าส่วนภูมิภาค', Icons.electrical_services),
          CallItem('1125', 'การประปานครหลวง', Icons.water_drop),
          CallItem('1662', 'ก๊าซหุงต้ม / ปตท.', Icons.local_gas_station),
        ],
      },
    };

    // Filter by category
    if (_selectedCategory == 'ทั้งหมด') {
      allSections.forEach((category, data) {
        Widget section = _buildSection(
          title: data['title'],
          calls: data['calls'],
        );
        if (section is! SizedBox) {
          sections.add(section);
          sections.add(SizedBox(height: 20));
        }
      });
    } else {
      if (allSections.containsKey(_selectedCategory)) {
        var data = allSections[_selectedCategory]!;
        Widget section = _buildSection(
          title: data['title'],
          calls: data['calls'],
        );
        if (section is! SizedBox) {
          sections.add(section);
          sections.add(SizedBox(height: 20));
        }
      }
    }

    return sections;
  }

  Widget _buildSection({required String title, required List<CallItem> calls}) {
    // Filter calls based on search query
    List<CallItem> filteredCalls = calls.where((call) {
      if (_searchQuery.isEmpty) return true;
      return call.number.toLowerCase().contains(_searchQuery) ||
             call.description.toLowerCase().contains(_searchQuery);
    }).toList();

    // Don't show section if no calls match the search
    if (filteredCalls.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF8B4A9F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...filteredCalls.map((call) => _buildCallButton(call)).toList(),
        ],
      ),
    );
  }

  Widget _buildCallButton(CallItem call) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _makePhoneCall(call.number),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF8B4A9F).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF8B4A9F).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B4A9F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  call.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.number,
                      style: TextStyle(
                        color: Color(0xFF8B4A9F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      call.description,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.phone,
                color: Color(0xFF8B4A9F),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $phoneNumber');
      }
    } catch (e) {
      print('Error launching phone call: $e');
    }
  }
}

class CallItem {
  final String number;
  final String description;
  final IconData icon;

  CallItem(this.number, this.description, this.icon);
}