import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';

class LiveRouteScreen extends StatefulWidget {
  const LiveRouteScreen({
    super.key,
    required this.api,
    required this.requestId,
    required this.riderName,
    required this.mechanicName,
    required this.pickupLocation,
    required this.etaMinutes,
  });

  final ApiService api;
  final String requestId;
  final String riderName;
  final String mechanicName;
  final String pickupLocation;
  final int etaMinutes;

  @override
  State<LiveRouteScreen> createState() => _LiveRouteScreenState();
}

class _LiveRouteScreenState extends State<LiveRouteScreen> {
  GoogleMapController? _controller;
  Timer? _timer;
  double _progress = 0.28;
  LatLng _riderLocation = const LatLng(0.3476, 32.5825);
  LatLng _mechanicLocation = const LatLng(0.3514, 32.5872);
  int _etaMinutes = 7;

  static const List<String> _statusLabels = [
    'On the way',
    'Approaching',
    'At pickup',
    'Service in progress',
  ];

  @override
  void initState() {
    super.initState();
    _etaMinutes = widget.etaMinutes;
    _loadRouteStatus();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadRouteStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadRouteStatus() async {
    try {
      final routeData = await widget.api.getLiveRouteForRider(widget.riderName == 'David' ? '1' : widget.requestId);
      if (routeData.isNotEmpty && mounted) {
        final liveRoute = routeData.first;
        final riderLat = (liveRoute['riderLatitude'] ?? _riderLocation.latitude) as num;
        final riderLng = (liveRoute['riderLongitude'] ?? _riderLocation.longitude) as num;
        final mechanicLat = (liveRoute['mechanicLatitude'] ?? _mechanicLocation.latitude) as num;
        final mechanicLng = (liveRoute['mechanicLongitude'] ?? _mechanicLocation.longitude) as num;
        final eta = (liveRoute['etaMinutes'] ?? _etaMinutes) as num;

        setState(() {
          _riderLocation = LatLng(riderLat.toDouble(), riderLng.toDouble());
          _mechanicLocation = LatLng(mechanicLat.toDouble(), mechanicLng.toDouble());
          _etaMinutes = eta.toInt();
          _progress = ((_etaMinutes / (widget.etaMinutes > 0 ? widget.etaMinutes : 1)).clamp(0.2, 0.95));
        });

        if (_controller != null) {
          await _controller!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _riderLocation.latitude < _mechanicLocation.latitude ? _riderLocation.latitude : _mechanicLocation.latitude,
                  _riderLocation.longitude < _mechanicLocation.longitude ? _riderLocation.longitude : _mechanicLocation.longitude,
                ),
                northeast: LatLng(
                  _riderLocation.latitude > _mechanicLocation.latitude ? _riderLocation.latitude : _mechanicLocation.latitude,
                  _riderLocation.longitude > _mechanicLocation.longitude ? _riderLocation.longitude : _mechanicLocation.longitude,
                ),
              ),
              80,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _progress = (_progress + 0.08).clamp(0.12, 0.95);
          _etaMinutes = (_etaMinutes - 1).clamp(1, 12);
        });
      }
    }
  }

  String get _currentStatus {
    if (_progress < 0.35) return _statusLabels[0];
    if (_progress < 0.65) return _statusLabels[1];
    if (_progress < 0.9) return _statusLabels[2];
    return _statusLabels[3];
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = <LatLng>[_riderLocation, _mechanicLocation];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: const Text('Live route'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Route tracking',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentStatus,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ETA $_etaMinutes min',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _riderLocation,
                      zoom: 13,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _controller = controller;
                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(
                          LatLngBounds(
                            southwest: LatLng(
                              _riderLocation.latitude < _mechanicLocation.latitude ? _riderLocation.latitude : _mechanicLocation.latitude,
                              _riderLocation.longitude < _mechanicLocation.longitude ? _riderLocation.longitude : _mechanicLocation.longitude,
                            ),
                            northeast: LatLng(
                              _riderLocation.latitude > _mechanicLocation.latitude ? _riderLocation.latitude : _mechanicLocation.latitude,
                              _riderLocation.longitude > _mechanicLocation.longitude ? _riderLocation.longitude : _mechanicLocation.longitude,
                            ),
                          ),
                          80,
                        ),
                      );
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('rider'),
                        position: _riderLocation,
                        infoWindow: InfoWindow(title: widget.riderName),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                      ),
                      Marker(
                        markerId: const MarkerId('mechanic'),
                        position: _mechanicLocation,
                        infoWindow: InfoWindow(title: widget.mechanicName),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: routePoints,
                        color: AppColors.orange,
                        width: 6,
                        patterns: [PatternItem.dot, PatternItem.gap(8)],
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pickupLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
