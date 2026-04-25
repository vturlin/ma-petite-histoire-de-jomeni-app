# Composants Jomeni — spécifications

Tous les exemples Flutter assument que tu importes :
```dart
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimens.dart';
```

## 1. Bouton primaire CTA (peach)

- Fond `accent1` (#F4C9B5)
- Texte `accentInk` (#5A2E1A)
- Radius `xl` (26)
- Min-height 56, padding 18
- Ombre `AppShadows.cta`

```dart
Container(
  decoration: BoxDecoration(boxShadow: AppShadows.cta),
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Continuer'),
  ),
);
```

## 2. Bouton secondaire (outline)

- Fond blanc, bordure `line` 2px, radius xl

```dart
OutlinedButton(onPressed: () {}, child: const Text('Retour'))
```

## 3. Card de sélection (option visuelle)

Carrée, radius `lg` (22), couleur de fond catégorielle (mint/butter/rose/lilac/sky), bordure 3px qui passe à `accent2` quand sélectionnée.

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.rose, // ou mint, butter…
    borderRadius: AppRadius.all(AppRadius.lg),
    border: Border.all(
      color: selected ? AppColors.accent2 : Colors.transparent,
      width: 3,
    ),
  ),
  child: AspectRatio(aspectRatio: 1, child: Center(child: characterIllus)),
);
```

## 4. Chip / pastille de choix

Radius `sm` (14), padding 12×16, fond blanc → `accentSoft` quand sélectionné, bordure `line` → `accent2` quand sélectionné.

```dart
Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  decoration: BoxDecoration(
    color: selected ? AppColors.accentSoft : Colors.white,
    border: Border.all(
      color: selected ? AppColors.accent2 : AppColors.line,
      width: 1.5,
    ),
    borderRadius: AppRadius.all(AppRadius.sm),
  ),
  child: Text(label, style: AppText.labelLarge),
);
```

## 5. Input texte avec icône préfixe

Radius `md` (18), bordure 2px, fond blanc, focus → bordure `accent2`. Géré par `inputDecorationTheme` du theme — il suffit d'un `TextField` standard.

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Le voyage de Augustine…',
    prefixIcon: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: AppRadius.all(AppRadius.xs),
      ),
      child: const Icon(Icons.menu_book, color: AppColors.accent2),
    ),
  ),
);
```

## 6. Top bar / app bar minimale

Pas d'AppBar Material classique — bouton retour rond + titre + bouton action rond, sur fond paper.

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _RoundIconBtn(icon: Icons.arrow_back, onTap: onBack),
      Text(title, style: AppText.titleLarge),
      _RoundIconBtn(icon: Icons.close, onTap: onClose),
    ],
  ),
);
```

`_RoundIconBtn` : 38×38, fond blanc, bordure `line` 1.5px, radius pill.

## 7. Avatar de personnage

Cercle avec dégradé doux. Pour les illustrations (lapin, ours, renard, chat, hibou, kid), utilise des SVG locaux — voir `screens.md` pour les assets.

```dart
Container(
  width: 132, height: 132,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [AppColors.accentSoft, AppColors.accent1],
    ),
    boxShadow: AppShadows.cta,
  ),
  child: Center(child: SvgPicture.asset('assets/illus/bunny.svg', width: 86)),
);
```

## 8. Progress bar

Hauteur 6–8px, fond `paper2`, fill en gradient `accent1 → accent2`, radius matching.

```dart
ClipRRect(
  borderRadius: AppRadius.all(8),
  child: LinearProgressIndicator(
    value: progress,
    minHeight: 8,
    backgroundColor: AppColors.paper2,
    valueColor: const AlwaysStoppedAnimation(AppColors.accent2),
  ),
);
```

## 9. Bouton play central (lecture)

78×78, cercle, fond `accent1`, ombre forte, icône play 32px.

## 10. Texture papier de fond

Le fond `paper` (#FBF6EC) suffit. Pour une vraie texture, superpose une `Image` PNG semi-transparente (un noise/grain doux) avec `BlendMode.multiply` et `opacity: 0.04` sur le Scaffold body.

Asset suggéré : un PNG 512×512 de bruit beige clair, tileable, exportable depuis Photoshop / Procreate.
