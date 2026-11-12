import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';

class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({
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
  State<MechanicDashboardScreen> createState() =>
      _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = false;
  bool _available = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _startLiveLocationTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLiveLocationTracking() async {
    if (widget.userId == null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are off. Turn them on to share your live GPS.')),
        );
      }
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission was not granted, so live driver updates are disabled.')),
        );
      }
      return;
    }

    await _pushLocationUpdate();
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!mounted || !_available) return;
      await _pushLocationUpdate(silent: true);
    });
  }

  Future<void> _pushLocationUpdate({bool silent = false}) async {
    if (widget.userId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await widget.api.updateMechanicLocation(
        mechanicId: widget.userId!,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live GPS is active.')),
        );
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to share live GPS: $e')),
        );
      }
    }
  }

  Future<void> _fetchRequests() async {
    if (widget.userId == null) return;
    setState(() => _loading = true);
    try {
      final requests = await widget.api.getMechanicRequests(widget.userId!);
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

  Future<void> _acceptRequest(String requestId) async {
    if (widget.userId == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.acceptRequest(
        requestId: requestId,
        mechanicId: widget.userId!,
      );
      await _fetchRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmRequest(String requestId) async {
    setState(() => _loading = true);
    try {
      await widget.api.confirmRequest(requestId);
      await _fetchRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(
    bool value, {
    ScaffoldMessengerState? messenger,
  }) async {
    if (widget.userId == null) return;
    try {
      await widget.api.updateMechanicAvailability(
        mechanicId: widget.userId!,
        available: value,
      );
      if (mounted) {
        setState(() => _available = value);
        if (value) {
          await _startLiveLocationTracking();
        } else {
          _locationTimer?.cancel();
        }
      }
    } catch (e) {
      if (mounted && messenger != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to update availability: $e')),
        );
      }
    }
  }

  List<_StatusStep> _statusSteps(String? rawStatus) {
    const labels = [
      'Requested',
      'Accepted',
      'Confirmed',
      'In progress',
      'Completed',
    ];

    final order = [
      'PENDING',
      'ACCEPTED',
      'CONFIRMED',
      'IN_PROGRESS',
      'COMPLETED',
    ];
    final activeIndex = order.indexOf((rawStatus ?? 'PENDING').toUpperCase());

    return List.generate(labels.length, (index) {
      final active = index <= (activeIndex >= 0 ? activeIndex : 0);
      return _StatusStep(
        label: labels[index],
        active: active,
        current: index == (activeIndex >= 0 ? activeIndex : 0),
      );
    });
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
                      'Mechanic dashboard',
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
                          'Available',
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today, 9:10 AM',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kato Motors Garage',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.verified_rounded, size: 16, color: AppColors.green),
                        SizedBox(width: 6),
                        Text(
                          'Verified mechanic',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: 'Earnings',
                            value: 'UGX 112k',
                            tint: AppColors.orangeLight,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            label: 'Jobs',
                            value: '${_requests.length} today',
                            tint: AppColors.paleGreen,
                            icon: Icons.build_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Available for nearby bookings',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Switch(
                            value: _available,
                            activeThumbColor: AppColors.green,
                            onChanged: (value) async {
                              final messenger = ScaffoldMessenger.of(context);
                              await _toggleAvailability(
                                value,
                                messenger: messenger,
                              );
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value ? 'You are now available' : 'You are now offline',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Incoming requests',
                style: TextStyle(
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
                          'No incoming requests.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      : Column(
                          children: _requests.map((req) {
                            final requestId = req['id']?.toString() ?? '';
                            final requestStatus = (req['status'] ?? 'PENDING').toString();
                            final normalizedStatus = requestStatus.toUpperCase();
                            final isAccepted = normalizedStatus == 'ACCEPTED';
                            final isConfirmed = normalizedStatus == 'CONFIRMED';
                            final isCompleted = normalizedStatus == 'COMPLETED';
                            final steps = _statusSteps(requestStatus);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppColors.orangeLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req['riderId']?.toString() ?? 'Rider',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            Text(
                                              req['requestType']?.toString() ?? '',
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
                                          color: isCompleted
                                              ? AppColors.paleGreen
                                              : AppColors.orangeLight,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          normalizedStatus,
                                          style: TextStyle(
                                            color: isCompleted ? AppColors.green : AppColors.orange,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
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
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: AppColors.muted,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          req['pickupLocation'] ?? 'Nearby pick-up',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: _loading
                                              ? null
                                              : () {
                                                  if (isAccepted || isConfirmed) {
                                                    _confirmRequest(requestId);
                                                  } else {
                                                    _acceptRequest(requestId);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isConfirmed
                                                ? AppColors.green
                                                : AppColors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            isAccepted ? 'Confirm' : isConfirmed ? 'Confirmed' : 'Accept',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
              const SizedBox(height: 22),
              const Text(
                'Quick tools',
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
                  _ActionChip(
                    icon: Icons.check_circle_rounded,
                    label: 'Accept',
                  ),
                  _ActionChip(icon: Icons.route_rounded, label: 'Route'),
                  _ActionChip(icon: Icons.inventory_2_rounded, label: 'Parts'),
                  _ActionChip(
                    icon: Icons.notifications_active_rounded,
                    label: 'Alerts',
                  ),
                ],
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
            _BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
            _BottomNavItem(
              icon: Icons.assignment_rounded,
              active: true,
              label: 'Jobs',
            ),
            _BottomNavItem(icon: Icons.chat_rounded, label: 'Inbox'),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.tint,
    required this.icon,
  });

  final String label;
  final String value;
  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.orange, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
