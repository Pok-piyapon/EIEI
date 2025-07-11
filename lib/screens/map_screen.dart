import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final List<Map<String, dynamic>>? allComplaints;

  const MapScreen({
    Key? key,
    required this.complaint,
    this.allComplaints,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng? _centerLocation;
  List<Marker> _markers = [];
  bool _showAllComplaints = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  void _initializeMap() {
    try {
      // Get the main complaint location
      final lat = double.tryParse(widget.complaint['ComplaintLat'].toString()) ?? 0.0;
      final lng = double.tryParse(widget.complaint['ComplaintLong'].toString()) ?? 0.0;
      
      if (lat != 0.0 && lng != 0.0) {
        _centerLocation = LatLng(lat, lng);
        _createMarkers();
      } else {
        // Default to Bangkok if no coordinates
        _centerLocation = LatLng(13.7563, 100.5018);
      }
    } catch (e) {
      // Default to Bangkok if error parsing coordinates
      _centerLocation = LatLng(13.7563, 100.5018);
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    if (_showAllComplaints && widget.allComplaints != null) {
      // Show all complaints
      for (final complaint in widget.allComplaints!) {
        final lat = double.tryParse(complaint['ComplaintLat'].toString()) ?? 0.0;
        final lng = double.tryParse(complaint['ComplaintLong'].toString()) ?? 0.0;
        
        if (lat != 0.0 && lng != 0.0) {
          _markers.add(_createMarker(complaint, lat, lng));
        }
      }
    } else {
      // Show only current complaint
      final lat = double.tryParse(widget.complaint['ComplaintLat'].toString()) ?? 0.0;
      final lng = double.tryParse(widget.complaint['ComplaintLong'].toString()) ?? 0.0;
      
      if (lat != 0.0 && lng != 0.0) {
        _markers.add(_createMarker(widget.complaint, lat, lng));
      }
    }
  }

  Marker _createMarker(Map<String, dynamic> complaint, double lat, double lng) {
    Color markerColor = _getStatusColor(complaint['ComplaintStatus']);
    bool isMainComplaint = complaint['ComplaintNumber'] == widget.complaint['ComplaintNumber'];
    
    return Marker(
      point: LatLng(lat, lng),
      width: isMainComplaint ? 60 : 40,
      height: isMainComplaint ? 60 : 40,
      child: GestureDetector(
        onTap: () => _showComplaintInfo(complaint),
        child: Container(
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isMainComplaint ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.white,
            size: isMainComplaint ? 30 : 20,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'รอดำเนินการ':
        return Colors.orange;
      case 'อยู่ระหว่างดำเนินการ':
        return Colors.blue;
      case 'เสร็จสิ้น':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showComplaintInfo(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Complaint number and status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B4A9F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF8B4A9F).withOpacity(0.3)),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint['ComplaintStatus']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(complaint['ComplaintStatus']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      complaint['ComplaintStatus'],
                      style: TextStyle(
                        color: _getStatusColor(complaint['ComplaintStatus']),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              
              // Type
              Text(
                complaint['ComplaintTypeName'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              if (complaint['ComplaintNote'].isNotEmpty) ...[
                SizedBox(height: 10),
                Text(
                  complaint['ComplaintNote'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              
              SizedBox(height: 15),
              
              // Location
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade400, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${complaint['ComplaintPlace']}${complaint['ComplaintStreetAlley'].isNotEmpty ? ', ${complaint['ComplaintStreetAlley']}' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              
              // Date
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey.shade500, size: 16),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(complaint['ComplaintDate']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerLocation ?? LatLng(13.7563, 100.5018),
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Color(0xFF8B4A9F)),
                  ),
                ),
                
                SizedBox(width: 10),
                
                // Title
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'ตำแหน่งเรื่องร้องเรียน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4A9F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom controls
          if (widget.allComplaints != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAllComplaints = !_showAllComplaints;
                                _createMarkers();
                              });
                            },
                            icon: Icon(
                              _showAllComplaints ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            label: Text(
                              _showAllComplaints ? 'แสดงเฉพาะรายการนี้' : 'แสดงทั้งหมด',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showAllComplaints ? Colors.grey : Color(0xFF8B4A9F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_showAllComplaints) ...[
                      SizedBox(height: 12),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem('รอดำเนินการ', Colors.orange),
                          _buildLegendItem('ดำเนินการ', Colors.blue),
                          _buildLegendItem('เสร็จสิ้น', Colors.green),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
