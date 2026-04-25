// Kept for backward compatibility — WizardScaffold renders its own progress bar.
// This widget is no longer used but kept to avoid import errors during migration.
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.all(8),
      child: LinearProgressIndicator(
        value: currentStep / totalSteps,
        minHeight: 6,
        backgroundColor: AppColors.paper2,
        valueColor: const AlwaysStoppedAnimation(AppColors.accent2),
      ),
    );
  }
}
