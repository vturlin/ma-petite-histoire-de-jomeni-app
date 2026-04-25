# Jomeni — Flutter Handoff

Design tokens et spécifications visuelles à appliquer à l'app Flutter Jomeni.

**Direction validée par le client :**
- Accent **Peach** (pêche chaleureux)
- Police titres **Nunito** (sans-serif arrondie)
- Texture papier doux activée
- Cartes en style "soft" (radius arrondis, ombres douces)
- Personnages illustrés dans des formes simples (lapin, ours, renard, chat, hibou)

## Contenu

- `tokens.md` — table de tous les tokens (couleurs, typo, radius, ombres, espacements)
- `app_theme.dart` — `ThemeData` Flutter prêt à coller
- `app_colors.dart` — palette en `Color` Flutter
- `app_text_styles.dart` — styles de texte Nunito
- `app_dimens.dart` — radius, espacements, tailles
- `screens.md` — mapping écran par écran (preview HTML → widget Flutter)
- `components.md` — spec des composants réutilisables (boutons, cards, inputs, chips)

## Comment l'utiliser avec Claude Code

1. Copie ce dossier `handoff/` à la racine de ton projet Flutter.
2. Ouvre Claude Code dans ton repo Flutter.
3. Donne-lui ce prompt :

> Lis tout le dossier `handoff/`. Adapte mon app Flutter Jomeni à cette nouvelle direction visuelle.
> Commence par installer le thème (`app_theme.dart`, `app_colors.dart`, `app_text_styles.dart`, `app_dimens.dart`) puis applique-le globalement via `MaterialApp(theme: ...)`.
> Ensuite, mets à jour les écrans un par un en suivant `screens.md`. Demande-moi avant de modifier une dépendance ou la structure des routes.

Claude Code aura tout ce qu'il faut.
