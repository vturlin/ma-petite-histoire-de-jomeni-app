import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              profile?.emoji ?? '👤',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 5),
            Text(
              profile?.name ?? 'Invité',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.expand_more, color: Colors.white38, size: 14),
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.white70),
              title: const Text(
                'Changer de profil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/profiles');
              },
            ),
            if (userProfileService.currentProfile != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white70),
                title: const Text(
                  'Modifier mon profil',
                  style: TextStyle(color: Colors.white),
                ),
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
