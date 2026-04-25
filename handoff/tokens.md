# Design Tokens — Jomeni

## Couleurs

### Neutres papier (fond, texte, bordures)
| Token | Hex | Usage |
|---|---|---|
| `paper` | `#FBF6EC` | Fond principal de l'app |
| `paper2` | `#F4ECDD` | Fond légèrement plus profond (cards passives, progress track) |
| `ink` | `#2D2620` | Texte principal |
| `inkSoft` | `#6B5F52` | Texte secondaire |
| `inkMute` | `#A89B8C` | Texte muted, captions |
| `line` | `#E5DAC6` | Bordures fines |
| `line2` | `#D6C9B0` | Bordures plus marquées, dashed |

### Accent — **Peach** (validé)
| Token | Hex | Usage |
|---|---|---|
| `accent1` | `#F4C9B5` | Boutons primaires, fills d'accent |
| `accent2` | `#E89F7E` | Bordures de sélection, icônes accent, gradient end |
| `accentSoft` | `#FBE7D5` | Fonds doux d'accent (chips sélectionnés, inputs focus) |
| `accentInk` | `#5A2E1A` | Texte sur accent fort (rare) |

### Couleurs auxiliaires (personnages, univers)
Utilisées comme fonds de cards par catégorie. **Ne pas changer** — elles donnent la variété visuelle.
| Token | Hex |
|---|---|
| `mint` | `#BFDDC9` |
| `sky` | `#C9DBEB` |
| `lilac` | `#D9CDE6` |
| `butter` | `#F4E2A8` |
| `rose` | `#EFC6CB` |
| `moss` | `#B7C4A0` |

## Typographie

**Police titres : Nunito** (Google Fonts) — weights 500, 600, 700, 800
**Police texte courant : Nunito** — weights 400, 500, 600

| Style | Font | Weight | Size | Line height | Usage |
|---|---|---|---|---|---|
| `displayLarge` | Nunito | 800 | 32 | 1.15 | Hero / "Bonjour, Augustine" |
| `headlineLarge` | Nunito | 700 | 26 | 1.2 | Titres d'écran ("Créons ton histoire") |
| `headlineMedium` | Nunito | 700 | 22 | 1.25 | Titres de section |
| `titleLarge` | Nunito | 700 | 18 | 1.3 | Titres de cards |
| `titleMedium` | Nunito | 600 | 16 | 1.4 | Labels de boutons |
| `bodyLarge` | Nunito | 500 | 15 | 1.5 | Texte courant |
| `bodyMedium` | Nunito | 500 | 14 | 1.5 | Sous-titres de cards |
| `bodySmall` | Nunito | 500 | 13 | 1.4 | Captions, metadata |
| `labelLarge` | Nunito | 600 | 14 | 1.3 | Chips |

## Border radius

| Token | Valeur | Usage |
|---|---|---|
| `rXs` | 10 | Petits chips, pastilles |
| `rSm` | 14 | Boutons secondaires, chips |
| `rMd` | 18 | Inputs, petites cards |
| `rLg` | 22 | Avatars carrés (profils, options visuelles) |
| `rXl` | 26 | Boutons primaires CTA, grandes cards |
| `r2xl` | 28 | Hero card de playback |
| `rPill` | 999 | Boutons icône circulaires |

## Espacements

Échelle 4-pt :
`s4: 4, s8: 8, s12: 12, s16: 16, s20: 20, s24: 24, s32: 32, s40: 40, s56: 56`

Padding écran standard : **20px horizontal**.

## Ombres

```dart
// shadowSoft — usage général sur cards
BoxShadow(
  color: Color(0x14463728), // rgba(70,55,40,0.08)
  blurRadius: 24,
  offset: Offset(0, 8),
)

// shadowButton — sur boutons primaires accent
BoxShadow(
  color: Color(0x40463728), // rgba(70,55,40,0.25)
  blurRadius: 30,
  offset: Offset(0, 14),
  spreadRadius: -14,
)

// Astuce : pour le "soft 3D" des boutons primaires, ajouter un inner highlight
// avec un Container superposé en gradient (pas natif en Flutter — voir components.md)
```

## Tailles cibles

- Boutons primaires CTA : **min-height 56px**, padding 18px
- Hit targets minimum : **44px**
- Avatars de profil : **88px** (grand) / **56px** (medium) / **40px** (petit)
- Boutons icône circulaires : **38px** (top bar) / **78px** (play central)
