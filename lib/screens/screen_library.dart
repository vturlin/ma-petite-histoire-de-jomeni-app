import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/saved_story.dart';
import '../services/story_library_service.dart';
import '../theme/app_theme.dart';

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
        backgroundColor: AppTheme.cardBg,
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Supprimer "${story.title}" et son audio ?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      '📚 Mes histoires',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_stories.length} histoire${_stories.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Liste
            Expanded(
              child: _stories.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _stories.length,
                      itemBuilder: (context, index) =>
                          _StoryCard(
                            story: _stories[index],
                            onTap: () => context.push('/play', extra: _stories[index]),
                            onDelete: () => _delete(_stories[index]),
                          ),
                    ),
            ),
          ],
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
          const Text(
            'Aucune histoire sauvegardée',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crée une histoire et appuie sur 💾 pour la sauvegarder',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
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
            color: Colors.redAccent.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false; // On gère la suppression dans onDelete
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                // Emoji thème
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(story.themeEmoji, style: const TextStyle(fontSize: 28)),
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
                        style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            story.hasAudio ? Icons.volume_up : Icons.volume_off,
                            size: 13,
                            color: story.hasAudio ? AppTheme.accent : Colors.white24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story.hasAudio
                                ? '${story.audioChunkCount} partie${story.audioChunkCount > 1 ? 's' : ''} audio'
                                : 'Pas d\'audio',
                            style: TextStyle(
                              color: story.hasAudio ? AppTheme.accent : Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(story.createdAt),
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.play_circle_fill, color: AppTheme.accent, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
