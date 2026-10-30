import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });

  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 23,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Step $step of $totalSteps',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}