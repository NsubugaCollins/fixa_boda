import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/step_header.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onBack,
    required this.onContinue,
  });

  final UserRole? selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final brands = ['Bajaj', 'TVS', 'Honda', 'Yamaha'];

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
                    onBack: onBack,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tell us about your bike',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'So mechanics arrive with the right parts and tools.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Make',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      final selected = selectedRole == UserRole.rider;
                      return ChoiceChip(
                        label: Text(brand),
                        selected: selected && brand == 'Bajaj',
                        onSelected: (_) => onRoleChanged(UserRole.rider),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.orangeLight,
                        side: const BorderSide(color: AppColors.border),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.orange : AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Model'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'Boxer 150',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Boxer 150', child: Text('Boxer 150')),
                      DropdownMenuItem(value: 'Boxer 100', child: Text('Boxer 100')),
                      DropdownMenuItem(value: 'Activa', child: Text('Activa')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Number plate'),
                  const SizedBox(height: 8),
                  const TextField(
                    decoration: InputDecoration(hintText: 'UFE 482K'),
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Year (optional)'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: '2021',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '2021', child: Text('2021')),
                      DropdownMenuItem(value: '2020', child: Text('2020')),
                      DropdownMenuItem(value: '2019', child: Text('2019')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Finish setup',
                      onPressed: onContinue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: onContinue,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(fontSize: 13),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
