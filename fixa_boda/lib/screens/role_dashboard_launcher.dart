import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'mechanic_dashboard_screen.dart';
import 'rider_dashboard_screen.dart';

enum AppRole { rider, mechanic }

class RoleDashboardLauncherScreen extends StatefulWidget {
  const RoleDashboardLauncherScreen({
    super.key,
    required this.api,
    this.token,
    this.userId,
    this.userRole,
  });

  final ApiService api;
  final String? token;
  final String? userId;
  final String? userRole;

  @override
  State<RoleDashboardLauncherScreen> createState() =>
      _RoleDashboardLauncherScreenState();
}

class _RoleDashboardLauncherScreenState
    extends State<RoleDashboardLauncherScreen> {
  AppRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    if (selectedRole == null) {
      return _RolePickerScreen(
        onSelect: (role) => setState(() => selectedRole = role),
      );
    }

    if (selectedRole == AppRole.rider) {
      return RiderDashboardScreen(
        api: widget.api,
        token: widget.token,
        userId: widget.userId,
        onBack: () => setState(() => selectedRole = null),
      );
    }

    return MechanicDashboardScreen(
      api: widget.api,
      token: widget.token,
      userId: widget.userId,
      onBack: () => setState(() => selectedRole = null),
    );
  }
}

class _RolePickerScreen extends StatelessWidget {
  const _RolePickerScreen({required this.onSelect});

  final ValueChanged<AppRole> onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose your role',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Rider',
                        subtitle: 'Need a mechanic fast',
                        icon: Icons.two_wheeler,
                        color: AppColors.orangeLight,
                        iconColor: AppColors.orange,
                        onTap: () => onSelect(AppRole.rider),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        title: 'Mechanic',
                        subtitle: 'Accept nearby jobs',
                        icon: Icons.handyman_outlined,
                        color: AppColors.paleGreen,
                        iconColor: AppColors.green,
                        onTap: () => onSelect(AppRole.mechanic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Connected to FIXABODA backend',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
