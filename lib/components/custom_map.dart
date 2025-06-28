import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoomLevel;

  // Constructor to accept lat, long, and optional zoom level
  const LocationMap({
    Key? key,
    this.latitude = 37.7749,
    this.longitude = -122.4194,
    this.zoomLevel = 15.0, // Default zoom level
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        // Updated options for `center` and `zoom` as per the new API
        initialCenter: LatLng(latitude, longitude),  // Use initialCenter instead of center
        initialZoom: zoomLevel,                      // Use initialZoom instead of zoom
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latitude, longitude), // Marker position
              child: const Icon(                 // `child` replaces `builder`
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
