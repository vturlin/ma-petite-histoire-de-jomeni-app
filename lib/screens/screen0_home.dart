import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/story_library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _savedCount = storyLibrary.count;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _savedCount = storyLibrary.count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surface, AppTheme.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const Spacer(),
                // Logo + titre
                Column(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 72))
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    const Text(
                      'Ma petite histoire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 6),
                    const Text(
                      'de Jomeni',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 10),
                    const Text(
                      'Des histoires magiques créées\nrien que pour toi ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.5),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
                const Spacer(),
                // Bouton "Créer une histoire"
                _HomeButton(
                  emoji: '🎨',
                  title: 'Créer une histoire',
                  subtitle: 'Invente une nouvelle aventure',
                  color: AppTheme.primary,
                  onTap: () => context.push('/create'),
                ).animate().slideY(begin: 0.3, delay: 500.ms, duration: 400.ms)
                    .fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
                // Bouton "Écouter une histoire"
                _HomeButton(
                  emoji: '🎧',
                  title: 'Écouter une histoire',
                  subtitle: _savedCount == 0
                      ? 'Aucune histoire sauvegardée'
                      : '$_savedCount histoire${_savedCount > 1 ? 's' : ''} sauvegardée${_savedCount > 1 ? 's' : ''}',
                  color: _savedCount == 0 ? Colors.grey.shade700 : AppTheme.secondary,
                  onTap: _savedCount == 0 ? null : () => context.push('/library'),
                ).animate().slideY(begin: 0.3, delay: 600.ms, duration: 400.ms)
                    .fadeIn(delay: 600.ms),
                const Spacer(),
                // Profil actif
                const ProfileButton().animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 6),
                const Text(
                  'Propulsé par Gemini AI',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _HomeButton({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.white.withValues(alpha: 0.08) : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: onTap == null ? Colors.white12 : color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: onTap == null ? Colors.white38 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: onTap == null ? Colors.white24 : Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: onTap == null ? Colors.white12 : color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
