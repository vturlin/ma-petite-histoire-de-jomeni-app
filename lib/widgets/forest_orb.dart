import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Carte de choix circulaire style "orbe enchanté".
class ForestOrb extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? orbColor;
  /// 92 = grille 3 col, 138 = grille 2 col, 160 = focus
  final double size;
  /// Chemin d'image asset optionnel (remplace l'emoji)
  final String? imageAsset;

  const ForestOrb({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.orbColor,
    this.size = 92,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final base = orbColor ?? AppColors.forestBg3;
    final gold = AppColors.forestGold;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 0.9,
                colors: [
                  Color.lerp(base, Colors.white, 0.25)!,
                  base,
                  Color.lerp(base, Colors.black, 0.3)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(color: gold.withValues(alpha: 0.9), blurRadius: 0, spreadRadius: 3),
                      BoxShadow(color: gold.withValues(alpha: 0.55), blurRadius: 28),
                      BoxShadow(color: gold.withValues(alpha: 0.25), blurRadius: 60),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                    ]
                  : [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6)),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Texture papier subtile
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(0.3, 0.3),
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
                // Contenu (image ou emoji)
                if (imageAsset != null)
                  ClipOval(
                    child: Image.asset(
                      imageAsset!,
                      width: size * 0.72,
                      height: size * 0.72,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Text(emoji, style: TextStyle(fontSize: size * 0.44)),
                // 3 points lumineux internes
                ..._sparkles(size),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Label · texte · en Fraunces italique
          Text(
            '· $label ·',
            style: AppText.microLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _sparkles(double size) {
    final positions = [
      const Alignment(-0.55, -0.55),
      const Alignment(0.6, -0.4),
      const Alignment(-0.3, 0.6),
    ];
    return positions.map((a) => Align(
      alignment: a,
      child: Container(
        width: size * 0.06,
        height: size * 0.06,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    )).toList();
  }
}
