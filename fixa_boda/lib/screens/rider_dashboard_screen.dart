import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'live_route_screen.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({
    super.key,
    required this.api,
    this.token,
    required this.userId,
    required this.onBack,
  });

  final ApiService api;
  final String? token;
  final String? userId;
  final VoidCallback onBack;

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _nearbyMechanics = [];
  bool _loading = false;
  bool _isFetchingLocation = false;
  Position? _currentPosition;

  static const double _riderLatitude = 0.3476;
  static const double _riderLongitude = 32.5825;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _currentPosition = null);
        }
        await _fetchNearbyMechanics(latitude: _riderLatitude, longitude: _riderLongitude);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      if (mounted) {
        setState(() => _currentPosition = position);
      }
      await _fetchNearbyMechanics(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      if (mounted) {
        setState(() => _currentPosition = null);
      }
      await _fetchNearbyMechanics(latitude: _riderLatitude, longitude: _riderLongitude);
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _fetchNearbyMechanics({double? latitude, double? longitude}) async {
    try {
      final mechanics = await widget.api.getNearbyMechanics(
        latitude: latitude ?? _riderLatitude,
        longitude: longitude ?? _riderLongitude,
      );
      if (mounted) setState(() => _nearbyMechanics = mechanics);
    } catch (_) {
      if (mounted) setState(() => _nearbyMechanics = const []);
    }
  }

  Future<void> _fetchRequests() async {
    if (widget.userId == null) return;
    setState(() => _loading = true);
    try {
      final requests = await widget.api.getRiderRequests(widget.userId!);
      if (mounted) setState(() => _requests = requests);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createRequest({
    required String requestType,
    required String description,
    required String pickupLocation,
    required String mechanicId,
  }) async {
    setState(() => _loading = true);
    try {
      await widget.api.createServiceRequest(
        riderId: widget.userId ?? '',
        requestType: requestType,
        description: description,
        pickupLocation: pickupLocation,
        destinationLocation: pickupLocation,
        mechanicId: mechanicId,
        estimatedCost: '20000',
      );
      await _fetchRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_StatusStep> _statusSteps(String? rawStatus) {
    const steps = [
      'Requested',
      'Accepted',
      'Confirmed',
      'In progress',
      'Completed',
    ];

    final normalized = (rawStatus ?? 'PENDING').toUpperCase();
    final order = [
      'PENDING',
      'ACCEPTED',
      'CONFIRMED',
      'IN_PROGRESS',
      'COMPLETED',
    ];
    final currentIndex = order.indexOf(normalized);
    final activeIndex = currentIndex >= 0 ? currentIndex : 0;

    return List.generate(steps.length, (index) {
      final isActive = index <= activeIndex;
      final isCurrent = index == activeIndex;
      return _StatusStep(
        label: steps[index],
        active: isActive,
        current: isCurrent,
      );
    });
  }

  Future<void> _openLiveRoute(Map<String, dynamic> request) async {
    final mechanicName = _nearestMechanic['name']?.toString() ?? 'Kato Motors';
    final etaMinutes = (_nearestMechanic['etaMinutes'] ?? 6) as int;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveRouteScreen(
          api: widget.api,
          requestId: (request['id'] ?? 1).toString(),
          riderName: 'David',
          mechanicName: mechanicName,
          pickupLocation: request['pickupLocation'] ?? 'Wandegeya, Kampala',
          etaMinutes: etaMinutes,
        ),
      ),
    );
  }

  Future<void> _showRequestSheet() async {
    final nearbyMechanics = List<Map<String, dynamic>>.from(_nearbyMechanics);
    final availableMechanics = nearbyMechanics.isNotEmpty
        ? nearbyMechanics
        : [
            {
              'id': '0',
              'name': 'No mechanic available',
              'available': false,
              'verified': false,
              'distanceKm': 0.0,
            },
          ];

    final descriptionController = TextEditingController(
      text: 'Need roadside assistance near my current location.',
    );
    final locationController = TextEditingController(text: 'Wandegeya, Kampala');
    String selectedServiceType = 'Flat tyre';
    String selectedMechanicId = availableMechanics.first['id'].toString();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a nearby mechanic',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedServiceType,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      'Flat tyre',
                      'Engine tune-up',
                      'Brake service',
                      'Battery change',
                      'Oil change',
                    ].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => selectedServiceType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMechanicId,
                    decoration: const InputDecoration(
                      labelText: 'Nearby mechanic',
                      border: OutlineInputBorder(),
                    ),
                    items: availableMechanics.map((mechanic) {
                      final verified = mechanic['verified'] == true;
                      final distance = mechanic['distanceKm'] ?? 0.0;
                      final label = verified
                          ? '${mechanic['name']} • ${distance.toStringAsFixed(1)} km • Verified'
                          : '${mechanic['name']} • ${distance.toStringAsFixed(1)} km';
                      return DropdownMenuItem<String>(
                        value: mechanic['id'].toString(),
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => selectedMechanicId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'What do you need?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send booking request'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != true) return;

    if (availableMechanics.first['id'] == '0') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No nearby mechanics are currently available. Try again shortly.')),
        );
      }
      return;
    }

    final type = selectedServiceType.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();
    if (type.isEmpty || description.isEmpty || location.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete the booking details.')),
        );
      }
      return;
    }

    await _createRequest(
      requestType: type,
      description: description,
      pickupLocation: location,
      mechanicId: selectedMechanicId,
    );
  }

  String get _nearestEtaLabel {
    if (_nearbyMechanics.isEmpty) {
      return 'ETA 6 min';
    }

    final nearest = _nearbyMechanics.firstWhere(
      (mechanic) => mechanic['etaMinutes'] is num,
      orElse: () => {'etaMinutes': 6},
    );
    final etaMinutes = nearest['etaMinutes'] as int? ?? 6;
    return 'ETA $etaMinutes min';
  }

  Map<String, dynamic> get _nearestMechanic {
    if (_nearbyMechanics.isEmpty) {
      return {
        'name': 'Kato Motors',
        'distanceKm': 3.2,
        'etaMinutes': 6,
        'rating': 4.9,
        'verified': true,
        'available': true,
      };
    }

    return _nearbyMechanics.first;
  }

  double get _routeProgress {
    final distance = (_nearestMechanic['distanceKm'] ?? 3.2) as num;
    final eta = (_nearestMechanic['etaMinutes'] ?? 6) as num;
    final normalized = (distance / 10.0).clamp(0.15, 0.9);
    final timeFactor = (1.0 - (eta / 20.0)).clamp(0.15, 0.9);
    return (normalized + timeFactor) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    padding: EdgeInsets.zero,
                  ),
                  const Expanded(
                    child: Text(
                      'Rider dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.green),
                        SizedBox(width: 6),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning, David',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentPosition != null
                          ? 'Live GPS • ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                          : 'Bajaj Boxer 150 • Wandegeya, Kampala',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEDE7E4), Color(0xFFFFF7F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 14,
                            top: 18,
                            child: _MapMarker(
                              color: AppColors.orange,
                              label: 'You',
                            ),
                          ),
                          Positioned(
                            right: 20,
                            top: 22,
                            child: _MapMarker(
                              color: AppColors.green,
                              label: _nearestMechanic['name']?.toString() ?? 'Mechanic',
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 65,
                            child: Container(
                              width: 150,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 65,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 150 * _routeProgress,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80 + (150 * _routeProgress) - 12,
                            top: 61,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${(_nearestMechanic['distanceKm'] ?? 3.2).toString()} km away • ${_nearestMechanic['verified'] == true ? 'Verified' : 'New'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _nearestEtaLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nearestMechanic['name']?.toString() ?? 'Kato Motors',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Service route • ${(_nearestMechanic['distanceKm'] ?? 3.2).toString()} km away',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orangeLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_nearestMechanic['rating'] ?? 4.9).toString()} ★',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _showRequestSheet,
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text('Request help'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nearby mechanics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              if (_nearbyMechanics.isEmpty)
                const Text(
                  'Searching for nearby mechanics...',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                Column(
                  children: _nearbyMechanics.take(3).map((mechanic) {
                    final name = mechanic['name'] ?? 'Mechanic';
                    final distance = (mechanic['distanceKm'] ?? 0.0) as num;
                    final etaMinutes = (mechanic['etaMinutes'] ?? 6) as int;
                    final rating = mechanic['rating'] ?? 4.8;
                    final verified = mechanic['verified'] == true;
                    final available = mechanic['available'] == true;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: available ? AppColors.paleGreen : AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              available ? Icons.build_rounded : Icons.schedule_rounded,
                              color: available ? AppColors.green : AppColors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    if (verified)
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: AppColors.green,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${distance.toDouble().toStringAsFixed(1)} km away • ETA $etaMinutes min • ${rating.toStringAsFixed(1)} ★',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: available ? AppColors.paleGreen : AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              available ? 'Available' : 'Busy',
                              style: TextStyle(
                                color: available ? AppColors.green : AppColors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              const Text(
                'Quick actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: const [
                  _ActionChip(icon: Icons.flash_on_rounded, label: 'Help'),
                  _ActionChip(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Fuel',
                  ),
                  _ActionChip(icon: Icons.payment_rounded, label: 'Pay'),
                  _ActionChip(icon: Icons.history_rounded, label: 'History'),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Your service requests (${_requests.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _requests.isEmpty
                      ? const Text(
                          'No requests yet. Tap "Request help" to create one.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      : Column(
                          children: _requests.map((req) {
                            final status = (req['status'] ?? 'PENDING').toString().toUpperCase();
                            final statusLabel = switch (status) {
                              'PENDING' => 'Requested',
                              'ACCEPTED' => 'Accepted',
                              'ARRIVED' => 'Mechanic arrived',
                              'CONFIRMED' => 'Confirmed',
                              'IN_PROGRESS' => 'In progress',
                              'COMPLETED' => 'Completed',
                              _ => status,
                            };

                            final steps = _statusSteps(status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req['requestType'] ?? 'Service request',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              req['pickupLocation'] ?? req['location'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'COMPLETED'
                                              ? AppColors.paleGreen
                                              : AppColors.orangeLight,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: status == 'COMPLETED'
                                                ? AppColors.green
                                                : AppColors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: steps.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final step = entry.value;
                                      return Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            right: index < steps.length - 1 ? 6 : 0,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: step.active
                                                ? AppColors.paleGreen
                                                : AppColors.background,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: step.active
                                                  ? AppColors.green
                                                  : AppColors.border,
                                            ),
                                          ),
                                          child: Text(
                                            step.label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: step.active ? AppColors.green : AppColors.muted,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: AppColors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified nearby mechanic',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openLiveRoute(req),
                                      icon: const Icon(Icons.map_rounded, size: 16),
                                      label: const Text('Track live route'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              active: true,
              label: 'Home',
            ),
            _BottomNavItem(icon: Icons.assignment_rounded, label: 'Jobs'),
            _BottomNavItem(icon: Icons.chat_rounded, label: 'Chat'),
            _BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.orange, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStep {
  const _StatusStep({
    required this.label,
    required this.active,
    required this.current,
  });

  final String label;
  final bool active;
  final bool current;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    this.active = false,
    required this.label,
  });

  final IconData icon;
  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? AppColors.orange : AppColors.muted),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? AppColors.orange : AppColors.muted,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
