import 'dart:async';

import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/step_header.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    super.key,
    required this.api,
    required this.data,
    required this.onBack,
    required this.register,
    required this.onSubmit,
    required this.onSignIn,
  });

  final ApiService api;
  final OnboardingData data;
  final VoidCallback onBack;
  final Future<void> Function() register;
  final VoidCallback onSubmit;
  final VoidCallback onSignIn;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    widget.data.fullName = _nameController.text.trim();
    widget.data.email = _emailController.text.trim();
    widget.data.phone = _phoneController.text.trim();

    if (widget.data.fullName.isEmpty ||
        widget.data.email.isEmpty ||
        widget.data.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      widget.data.fullName = _nameController.text.trim();
      widget.data.email = _emailController.text.trim();
      widget.data.phone = _phoneController.text.trim();

      if (widget.data.fullName.isEmpty ||
          widget.data.email.isEmpty ||
          widget.data.phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }

      await widget.register();
      if (mounted) widget.onSubmit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailSelected = widget.data.contactMethod == ContactMethod.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final body = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepHeader(
                    step: 2,
                    totalSteps: 4,
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create your account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your account and then sign in to continue.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E7E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MethodTab(
                            label: 'Phone',
                            active: !emailSelected,
                            onTap: () => setState(() => widget.data.contactMethod = ContactMethod.phone),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _MethodTab(
                            label: 'Email',
                            active: emailSelected,
                            onTap: () => setState(() => widget.data.contactMethod = ContactMethod.email),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Full name'),
                  const SizedBox(height: 8),
                  _TextInput(
                    controller: _nameController,
                    hintText: 'Semakula David',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Email address'),
                  const SizedBox(height: 8),
                  _TextInput(
                    controller: _emailController,
                    hintText: 'david.semakula@gmail.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Phone number (for calls & payments)'),
                  const SizedBox(height: 8),
                  _TextInput(
                    controller: _phoneController,
                    hintText: '+256 701 234 567',
                    prefixIcon: Icons.phone_iphone_outlined,
                    prefixText: 'UG +256 ',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.orange, width: 1.5),
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.check, size: 14, color: AppColors.orange),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'I agree to the FIXABODA Terms of Service and Privacy Policy.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Create account',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _submitting ? null : _handleSubmit,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: widget.onSignIn,
                      child: const Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: body,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class VerifyEmailCodeScreen extends StatelessWidget {
  const VerifyEmailCodeScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
    required this.email,
  });

  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final String email;

  @override
  Widget build(BuildContext context) {
    final numbers = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '⌫',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final body = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepHeader(
                    step: 3,
                    totalSteps: 4,
                    onBack: onBack,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Verify your email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Code sent to ',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onBack,
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _CodeDigitBox('4'),
                      _CodeDigitBox('8'),
                      _CodeDigitBox('2'),
                      _CodeDigitBox('9'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Didn't get the code? Resend in 0:24",
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.7,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      physics: const NeverScrollableScrollPhysics(),
                      children: numbers.map((value) {
                        if (value.isEmpty) {
                          return const SizedBox();
                        }

                        final isDelete = value == '⌫';
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDelete ? AppColors.border : Colors.transparent,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isDelete ? '⌫' : value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Verify and continue',
                      onPressed: onSubmit,
                    ),
                  ),
                ],
              );

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: body,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.prefixText,
  });

  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.muted),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeDigitBox extends StatelessWidget {
  const _CodeDigitBox(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
