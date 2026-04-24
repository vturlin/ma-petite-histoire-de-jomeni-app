import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.white24,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
