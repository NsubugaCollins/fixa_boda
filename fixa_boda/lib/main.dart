import 'dart:async';
import 'package:flutter/material.dart';

import 'screens/onboarding_flow.dart';
import 'screens/role_dashboard_launcher.dart';
import 'screens/welcome_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FixabodaApp());
}

class FixabodaApp extends StatefulWidget {
  const FixabodaApp({super.key});

  @override
  State<FixabodaApp> createState() => _FixabodaAppState();
}

class _FixabodaAppState extends State<FixabodaApp> {
  late final ApiService _api;
  bool _showWelcome = true;
  bool _showDashboard = false;
  int _onboardingStartStep = 0;
  String? _token;
  String? _userId;
  String? _userRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _login({required String email, required String password}) async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.login(email: email, password: password);
      _token = data['token'] as String?;
      _userId = data['userId'] as String?;
      _userRole = data['role'] as String?;
      if (mounted) {
        setState(() {
          _showWelcome = false;
          _showDashboard = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }

  Future<void> _register({
    required String fullName,
    required String email,
    required String phone,
    required String role,
  }) async {
    setState(() => _isLoading = true);
    try {
      await _api.register(
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
      );
      if (mounted) {
        setState(() {
          _showWelcome = false;
          _showDashboard = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  void _openOnboarding() {
    setState(() {
      _showWelcome = false;
      _showDashboard = false;
      _onboardingStartStep = 0;
    });
  }

  void _openSignIn() {
    setState(() {
      _showWelcome = false;
      _showDashboard = false;
      _onboardingStartStep = 6;
    });
  }

  void _openDashboard() {
    setState(() {
      _showWelcome = false;
      _showDashboard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIXABODA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _showWelcome
              ? WelcomeScreen(
                  onCreateAccount: _openOnboarding,
                  onSignIn: _openSignIn,
                )
              : _showDashboard
                  ? RoleDashboardLauncherScreen(
                      api: _api,
                      token: _token,
                      userId: _userId,
                      userRole: _userRole,
                    )
                  : OnboardingFlow(
                      api: _api,
                      startStep: _onboardingStartStep,
                      onComplete: _openDashboard,
                      register: _register,
                      login: _login,
                    ),
    );
  }
}
