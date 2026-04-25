# Mapping écrans — preview HTML → Flutter

Ouvre `Jomeni.html` à côté pour comparer visuellement.

Personnages utilisés (5) : **bunny** (lapin), **bear** (ours), **fox** (renard), **cat** (chat), **owl** (hibou) + **kid** (avatar enfant générique).
À exporter en SVG et ranger dans `assets/illus/`.

---

## Écran 1 — Sélection de profil

**Route suggérée : `/profile-select`**

- Fond `paper` (texture papier optionnelle).
- Titre centré "Qui écoute aujourd'hui ?" en `headlineLarge`.
- Grille 2 colonnes de **cards de profil carrées** (radius `lg`).
  - Chaque card : couleur catégorielle (rose, peach, butter, sky, lilac), illustration personnage centrée, nom + âge dessous.
  - Card sélectionnée → bordure 3px `accent2`.
- Bouton CTA bas : "C'est moi !" → primaire peach.

Profils par défaut :
| id | nom | âge | personnage | bg |
|---|---|---|---|---|
| augustine | Augustine | 4 | bunny | rose |
| leo | Léo | 6 | fox | accentSoft |
| mila | Mila | 3 | bear | butter |
| ethan | Ethan | 8 | owl | sky |
| rose | Rose | 5 | cat | lilac |

---

## Écran 2 — Accueil

**Route : `/home`**

Structure verticale :
1. **Top bar** : bouton profil rond (gauche) + bouton paramètres rond (droite).
2. **Avatar** circulaire 132px, gradient `accentSoft → accent1`, illustration enfant au centre.
3. **Salutation** : "Bonjour, {nom}" en `displayLarge` + sous-titre `bodyMedium` "Que veux-tu faire aujourd'hui ?"
4. **Card "Créer une histoire"** (CTA primaire) : fond `accent1`, radius `xl`, hauteur min 96, icône baguette magique dans un carré `accentSoft` 72×72 à gauche, texte 2 lignes ("Créer une histoire" / "Une nouvelle aventure"), chevron rond blanc à droite.
5. **Card "Écouter une histoire"** : fond blanc, bordure `line` 2px, radius `xl`, icône casque + notes dans un carré `sky` à gauche, désactivée si aucune histoire sauvegardée.
6. **Compteur d'histoires** sauvegardées (style `bodySmall`).

Blobs décoratifs : 2 cercles flous en absolute (top-right `accent1` 45% opacity, bottom-left `sky` 50% opacity).

---

## Écran 3 — Wizard 5 étapes

**Route : `/wizard` avec un `IndexedStack` ou `PageView` géré par bloc/provider.**

Pattern commun à chaque étape :
- Top bar : bouton retour rond + indicateur "Étape N/5" centré + bouton fermer rond.
- En-tête `StepHeading` :
  - Pastille colorée (couleur thématique de l'étape) avec une icône SVG.
  - Titre `headlineMedium`.
  - Sous-titre `bodyMedium`.
- Contenu scrollable.
- Footer fixe : bouton "Retour" (outline) à gauche + bouton "Continuer" (primaire) à droite. Sur la dernière étape : "Créer l'histoire" avec icône étoile.

| Step | Titre | Pastille | Contenu |
|---|---|---|---|
| 0 | Créons ton histoire | accentSoft + livre ouvert | Input texte titre + 4 chips "suggestions" (Le voyage de…, La forêt mystérieuse, …) |
| 1 | Qui est le héros ? | rose + lapin | Grille 2×3 de cards personnages (me, bunny, bear, fox, cat, owl) |
| 2 | Choisis l'univers | mint + globe | Grille 2×2 cards univers (Forêt, Océan, Désert, Montagne) — illustrations larges 1.5:1 |
| 3 | Type d'histoire | butter + parchemin | Liste verticale 4 lignes (Aventure, Enquête, Conte de fée, Voyage) avec icône à gauche, sous-titre, check `accent2` à droite si sélectionné |
| 4 | L'objet magique | lilac + baguette | Input texte + grille 3 colonnes de chips visuels (Baguette, Plume, Carte, Boussole, Étoile, Clé) |

---

## Écran 4 — Loading / génération

**Route : `/loading` (transitionnelle, ~3s)**

- Centré verticalement.
- Cercle 130px gradient `accentSoft → accent1`, contenant une illustration de livre, qui pulse (scale 1 → 1.05 → 1, 1.5s, easeInOut, infinite).
- Titre `headlineMedium` au-dessous + sous-titre dynamique qui change selon la phase :
  1. "On invente le décor…"
  2. "On rencontre les personnages…"
  3. "On écrit l'histoire…"
  4. "On met en musique…"
- Progress bar en bas (220px), gradient `accent1 → accent2`, qui se remplit au fil des phases.
- Quand 100% → push remplaçant vers `/playback`.

---

## Écran 5 — Playback

**Route : `/playback`**

- Top bar : retour + favori.
- **Hero card** 320px, radius `xxl` (28), fond = gradient catégoriel selon univers de l'histoire (forêt = vert, océan = bleu, désert = jaune, montagne = bleu froid). Personnage illustré centré, badge titre semi-transparent en bas.
- Titre de l'histoire `headlineLarge` + métadonnées (auteur, durée).
- **Progress** mince (6px) avec timestamps "01:23 / 04:30".
- **Contrôles** centrés : bouton -15s / **Play 78px peach** / bouton +15s.
- Boutons secondaires : vitesse (1×), texte, partager.

L'animation de progression doit persister dans `localStorage` équivalent côté Flutter (`shared_preferences`) — clé `playback_position_{storyId}`, lue au démarrage.

---

## Notes générales pour Claude Code

- N'invente pas de nouvelles couleurs : tout est dans `AppColors`.
- Les **dégradés** sont tous diagonaux (160°) : `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, ...)` est une bonne approximation.
- Pour les **icônes SVG personnages**, exporte-les depuis le HTML preview ou demande à l'utilisateur de fournir les assets (les SVG inline du preview sont dans `characters.jsx` et `screens.jsx`).
- Police : **Nunito uniquement**, partout.
- Le wizard doit être **navigable au clavier / accessible** (focus logique, ordre de tabulation correct).
