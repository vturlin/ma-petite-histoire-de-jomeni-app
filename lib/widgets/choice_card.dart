import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class ChoiceCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? bgColor;
  final double emojiSize;
  /// Si fourni, affiche une image asset à la place de l'emoji.
  final String? imageAsset;

  const ChoiceCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.bgColor,
    this.emojiSize = 40,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final base = bgColor ?? AppColors.paper2;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: base,
          borderRadius: AppRadius.all(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.accent2 : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected ? AppShadows.soft : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageAsset != null
                ? Image.asset(imageAsset!, width: emojiSize * 1.4,
                    height: emojiSize * 1.4, fit: BoxFit.contain)
                : Text(emoji, style: TextStyle(fontSize: emojiSize)),
            const SizedBox(height: AppSpacing.s8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: isSelected
                    ? AppText.labelLarge.copyWith(color: AppColors.accentInk)
                    : AppText.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
