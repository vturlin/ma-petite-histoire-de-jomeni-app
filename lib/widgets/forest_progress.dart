import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Progression par lucioles dorées (remplace StepProgress).
class ForestProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ForestProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final done = i < currentStep;
        final current = i == currentStep - 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: current ? 14 : 8,
            height: current ? 14 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || current
                  ? AppColors.forestGold
                  : AppColors.forestGold.withValues(alpha: 0.2),
              boxShadow: current
                  ? [
                      BoxShadow(
                        color: AppColors.forestGold.withValues(alpha: 0.7),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
