import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/saved_story.dart';
import '../services/story_library_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/forest_background.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<SavedStory> _stories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _stories = storyLibrary.getAll());

  Future<void> _delete(SavedStory story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forestBg2,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.xl)),
        title:
            Text('Supprimer ?', style: AppText.titleLarge),
        content: Text(
          'Supprimer "${story.title}" et son audio ?',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style: AppText.labelLarge.copyWith(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer',
                style:
                    AppText.labelLarge.copyWith(color: AppColors.forestBerry)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await storyLibrary.delete(story.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestBg1,
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.forestBg2,
                          border: Border.all(
                            color:
                                AppColors.forestCream.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.forestCream, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Mes histoires',
                        textAlign: TextAlign.center,
                        style: AppText.titleSerif,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.forestGold.withValues(alpha: 0.15),
                        borderRadius: AppRadius.all(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.forestGold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_stories.length}',
                        style: AppText.labelLarge
                            .copyWith(color: AppColors.forestGold),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              // Liste
              Expanded(
                child: _stories.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _stories.length,
                        itemBuilder: (context, index) => _StoryCard(
                          story: _stories[index],
                          onTap: () =>
                              context.push('/play', extra: _stories[index]),
                          onDelete: () => _delete(_stories[index]),
                        ).animate().fadeIn(
                            delay: Duration(milliseconds: index * 60),
                            duration: 300.ms),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Aucune histoire sauvegardée',
            style: AppText.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crée une histoire et appuie sur 💾 pour la sauvegarder',
            textAlign: TextAlign.center,
            style: AppText.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create'),
            icon: const Icon(Icons.add),
            label: const Text('Créer une histoire'),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final SavedStory story;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StoryCard({
    required this.story,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(story.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.forestBerry.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.forestCream,
              size: 28),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forestBg2,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                  color: AppColors.forestCream.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                // Emoji thème
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.forestGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.forestGold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(story.themeEmoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title.isEmpty ? 'Histoire sans titre' : story.title,
                        style: AppText.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.subtitle,
                        style: AppText.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            story.hasAudio
                                ? Icons.volume_up
                                : Icons.volume_off,
                            size: 13,
                            color: story.hasAudio
                                ? AppColors.forestGold
                                : AppColors.inkMute,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story.hasAudio
                                ? '${story.audioChunkCount} partie${story.audioChunkCount > 1 ? 's' : ''} audio'
                                : 'Pas d\'audio',
                            style: AppText.bodySmall.copyWith(
                              color: story.hasAudio
                                  ? AppColors.forestGold
                                  : AppColors.inkMute,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(story.createdAt),
                            style: AppText.bodySmall
                                .copyWith(color: AppColors.inkMute),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forestGold.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.forestGold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.forestGold, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
