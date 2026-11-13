import 'dart:async';

import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/api_service.dart';
import 'create_account_screen.dart';
import 'verification_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.api,
    this.startStep = 0,
    this.onComplete,
    required this.register,
    required this.login,
  });

  final ApiService api;
  final int startStep;
  final VoidCallback? onComplete;
  final Future<void> Function({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) register;
  final Future<void> Function({required String email, required String password}) login;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final OnboardingData data = OnboardingData();

  late int currentStep;

  void goTo(int step) {
    setState(() {
      currentStep = step;
    });
  }

  Future<void> _handleRegister() async {
    if (data.role == null ||
        data.fullName.isEmpty ||
        data.email.isEmpty ||
        data.phone.isEmpty ||
        data.password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role and fill in all fields.')),
      );
      return;
    }
    final role = data.role == UserRole.mechanic ? 'MECHANIC' : 'RIDER';
    await widget.register(
      fullName: data.fullName,
      email: data.email,
      phone: data.phone,
      role: role,
      password: data.password,
    );
  }

  Future<void> _handleSignIn({required String email, required String password}) async {
    await widget.login(email: email, password: password);
    if (mounted && widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void initState() {
    super.initState();
    currentStep = widget.startStep;
  }

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case 0:
        return CreateAccountScreen(
          api: widget.api,
          data: data,
          onBack: () => goTo(1),
          register: _handleRegister,
          onSubmit: () => goTo(1),
          onSignIn: () => goTo(1),
        );
      case 1:
        return WelcomeBackScreen(
          api: widget.api,
          onCreateAccount: () => goTo(0),
          onSignIn: _handleSignIn,
        );
      default:
        return CreateAccountScreen(
          api: widget.api,
          data: data,
          onBack: () => goTo(1),
          register: _handleRegister,
          onSubmit: () => goTo(1),
          onSignIn: () => goTo(1),
        );
    }
  }
}
