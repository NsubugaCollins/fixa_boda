import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onCreateAccount,
    required this.onSignIn,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  18, 12, 18, 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.orange,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 6,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                                width: 22,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 48,
                          child: Column(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.build_outlined,
                                  color: AppColors.orange,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'FIXABODA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 21,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const SizedBox(
                                width: 230,
                                child: Text(
                                  'Roadside help for every boda '
                                  'rider in Uganda',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Positioned(
                          left: 12,
                          top: 168,
                          child: _FloatingNotice(
                            icon: Icons.two_wheeler,
                            title: 'Flat tyre · Wandegeya',
                            subtitle: 'Rider needs help',
                            tint: AppColors.orangeLight,
                          ),
                        ),
                        const Positioned(
                          right: 12,
                          top: 204,
                          child: _FloatingNotice(
                            icon: Icons.check_circle,
                            title: 'Mechanic accepted',
                            subtitle: 'Arriving in 6 min',
                            tint: AppColors.paleGreen,
                            iconColor: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  30, 20, 30, 20,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 20,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Breakdown? Help is\nminutes away.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Connect with verified mechanics near\n'
                      'you, or get callouts as a mechanic.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Create account',
                      onPressed: onCreateAccount,
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      height: 43,
                      child: OutlinedButton(
                        onPressed: onSignIn,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'I already have an account',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _SystemBar(),
    );
  }
}

class _FloatingNotice extends StatelessWidget {
  const _FloatingNotice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    this.iconColor = AppColors.orange,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemBar extends StatelessWidget {
  const _SystemBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      color: AppColors.background,
      alignment: Alignment.center,
      child: Container(
        width: 68,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}