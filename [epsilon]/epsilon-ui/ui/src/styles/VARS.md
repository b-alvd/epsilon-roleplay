# CSS Variables — Epsilon UI

Toutes les variables sont déclarées dans `src/styles/globals.css` (`:root`).

---

## Polices

| Variable | Valeur | Usage |
|---|---|---|
| `--font-ui` | Lato | Texte courant, boutons, labels |
| `--font-display` | Montserrat | Titres, logo, watermark |
| `--font-hand` | Caveat | Texte manuscrit décontracté |
| `--font-script` | Mrs Saint Delafield | Texte calligraphié élégant |

---

## Layout

| Variable | Valeur | Usage |
|---|---|---|
| `--panel-w` | `370px` | Largeur du panel latéral (screens Select/Create) |
| `--r` | `6px` | Border-radius global (cards, inputs, boutons) |

---

## Dégradés

| Variable | Usage |
|---|---|
| `--panel-grad` | Fond du panel character select (transparent → noir → transparent, vertical). Modifier ici pour ajuster l'intensité du dégradé en jeu. |
| `--panel-grad2` | Dégradé horizontal gauche→droite (utilisé sur le watermark du nom). |
| `--grad` | Dégradé gris hérité (non utilisé activement — conservé pour référence) |

---

## Couleurs — Fond des cartes

| Variable | Valeur | Usage |
|---|---|---|
| `--card-bg` | `rgba(38,38,38,0.92)` | Slot card normal |
| `--card-sel` | `rgba(80,90,180,0.55)` | Slot card sélectionné |
| `--card-empty` | `rgba(32,32,32,0.88)` | Slot card vide |
| `--card-hover` | `rgba(55,55,55,0.95)` | Slot card au survol |

---

## Couleurs — Texte

| Variable | Valeur | Usage |
|---|---|---|
| `--text` | `#e8e8ec` | Texte principal |
| `--muted` | `#a0a0a8` | Texte secondaire, métadonnées |
| `--dim` | `#666670` | Labels, texte très discret |

---

## Couleurs — UI

| Variable | Valeur | Usage |
|---|---|---|
| `--border` | `rgba(255,255,255,0.08)` | Bordures subtiles partout |
| `--accent` | `#6c63ff` | Violet principal (tabs actifs, logo dot, sliders) |
| `--accent-d` | `rgba(108,99,255,0.25)` | Accent transparent (fond bouton genre actif) |
| `--green` | `#4e7a5e` | Bouton primaire (Jouer, Créer) |
| `--green-h` | `#5d8f6e` | Bouton primaire au hover |
| `--red` | `#ef4444` | Erreurs formulaire |
