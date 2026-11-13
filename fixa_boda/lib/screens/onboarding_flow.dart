import 'dart:async';

import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/api_service.dart';
import 'create_account_screen.dart';
import 'role_selection_screen.dart';
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
    if (data.fullName.isEmpty || data.email.isEmpty || data.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    final role = data.role == UserRole.mechanic ? 'MECHANIC' : 'RIDER';
    await widget.register(
      fullName: data.fullName,
      email: data.email,
      phone: data.phone,
      role: role,
    );
  }

  Future<void> _handleSignIn({required String email, required String password}) async {
    await widget.login(email: email, password: password);
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
          onBack: () => goTo(0),
          register: _handleRegister,
          // The verification-code step is intentionally disabled for now.
          // After creating an account, users are sent straight to the sign-in screen.
          onSubmit: () => goTo(6),
          onSignIn: () => goTo(6),
        );
      case 1:
        return WelcomeBackScreen(
          api: widget.api,
          onCreateAccount: () => goTo(0),
          onSignIn: _handleSignIn,
        );
      case 2:
        return RoleSelectionScreen(
          selectedRole: data.role,
          onRoleChanged: (role) {
            setState(() {
              data.role = role;
            });
          },
          onBack: () => goTo(1),
          onContinue: () => goTo(3),
        );
      case 3:
        return VerificationScreen(
          api: widget.api,
          data: data,
          onBack: () => goTo(2),
          onSubmit: () => goTo(4),
        );
      case 4:
        return ApplicationSubmittedScreen(
          onContinue: widget.onComplete ?? () => goTo(5),
        );
      case 5:
        return AllSetScreen(
          onContinue: widget.onComplete ?? () => goTo(6),
        );
      case 6:
        return WelcomeBackScreen(
          api: widget.api,
          onCreateAccount: () => goTo(0),
          onSignIn: _handleSignIn,
        );
      default:
        return CreateAccountScreen(
          api: widget.api,
          data: data,
          onBack: () => goTo(0),
          register: _handleRegister,
          onSubmit: () => goTo(6),
          onSignIn: () => goTo(6),
        );
    }
  }
}
