import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'profile_sheet.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  @override
  Widget build(BuildContext context) {
    final profile = userProfileService.currentProfile;
    return GestureDetector(
      onTap: _showOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.all(AppRadius.pill),
          border: Border.all(color: AppColors.line, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(profile?.emoji ?? '👤',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.s4),
            Text(
              profile?.name ?? 'Invité',
              style: AppText.labelLarge,
            ),
            const SizedBox(width: AppSpacing.s4),
            const Icon(Icons.expand_more,
                color: AppColors.inkMute, size: 16),
          ],
        ),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppSpacing.s16),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.all(AppRadius.xxl),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: AppRadius.all(AppRadius.pill),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz,
                  color: AppColors.inkSoft),
              title: Text('Changer de profil', style: AppText.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                context.push('/profiles');
              },
            ),
            if (userProfileService.currentProfile != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined,
                    color: AppColors.inkSoft),
                title: Text('Modifier mon profil', style: AppText.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSheet();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet() {
    final profile = userProfileService.currentProfile;
    if (profile == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(
        existingProfile: profile,
        onSaved: (_) => setState(() {}),
        onDeleted: () => context.go('/profiles'),
      ),
    );
  }
}
