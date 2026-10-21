# Dictionnaire des données

Tous les fichiers sont en **CSV, séparateur point-virgule, encodage UTF-8**. Ce format s'ouvre correctement dans Excel et LibreOffice en français. Pour les lire : `pandas.read_csv(fichier, sep=";")` en Python, `read.csv2(fichier)` en R. Les décimales peuvent s'écrire `12,5` ou `12.5` : le script accepte les deux.

## Colonne `statut`

| Valeur | Sens | Chargé dans la base ? |
|---|---|---|
| `ok` | ligne complète | oui |
| `a_valider` | remplie mais à relire (texte provisoire, niveau à définir…) | oui, signalée |
| `a_completer` | pas encore remplie | non (sauf `modules`, toujours chargés) |

## Sources et état de chaque fichier

| Fichier | Contenu | Source | État actuel |
|---|---|---|---|
| `competences.csv` | les 4 compétences du parcours VCOD | Programme national BUT Science des données (2022, mis à jour en 2023) | complet |
| `apprentissages_critiques.csv` | 54 apprentissages critiques par compétence et niveau | même programme, libellés raccourcis et reformulés | complet |
| `semestres.csv` | S1 à S6 : année, volumes nationaux, semaines de stage, validation | même programme + ma situation | volumes complets ; **statut de validation et moyennes à saisir** |
| `modules.csv` | catalogue des ressources, SAÉ et stages de S1 à S6 | même programme | codes et intitulés complets ; **compétence et heures complètes pour S1 seulement** |
| `notes.csv` | une ligne par évaluation | mes relevés de notes | **modèle prérempli (S1 à S4), notes à saisir** |
| `technologies.csv` | outils et langages affichés dans les cartes | mes cours et mes projets | liste à valider, **niveaux à définir** |
| `projets.csv` | projets affichés dans la section Projets | saisie manuelle | 1 projet complet, 1 à valider |
| `projets_technologies.csv` | lien projet ↔ technologie | saisie manuelle | cohérent avec `projets.csv` |
| `documents.csv` | CV, attestations, rapports | mes fichiers | 1 rapport (maquette), CV à ajouter |

## Tables

### competences
| Colonne | Type | Description |
|---|---|---|
| `code` | texte | `C1` à `C4` (clé) |
| `nom_court` | texte | Traiter, Analyser, Valoriser, Développer |
| `intitule` | texte | intitulé officiel |
| `description_courte` | texte | phrase affichée dans la carte |

### apprentissages_critiques
| Colonne | Type | Description |
|---|---|---|
| `code` | texte | code officiel, ex. `AC11.01` (clé) |
| `competence_code` | texte | compétence rattachée |
| `niveau` | entier 1 à 3 | niveau de développement de la compétence (C4 : 1 à 2) |
| `intitule_niveau` | texte | ex. « Traiter des données structurées » |
| `libelle_court` | texte | formulation courte affichée dans le panneau de détail |

### semestres
| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `S1` à `S6` (clé) |
| `annee_but` | entier 1 à 3 | année de BUT |
| `annee_universitaire` | texte | ex. `2025-2026` |
| `heures_enseignement_nationales` | entier | volume national d'enseignement (ressources + SAÉ) |
| `heures_projet_tutore_nationales` | entier | volume national de projet tutoré |
| `stage_semaines_min`, `stage_semaines_max` | entier | fourchette nationale de stage |
| `statut_validation` | texte | `valide`, `en_cours`, `a_venir`, `a_saisir`, `non_valide` |
| `moyenne_officielle` | réel 0 à 20 | moyenne du relevé, sert de contrôle |
| `commentaire` | texte | libre |

### modules
| Colonne | Type | Description |
|---|---|---|
| `code` | texte | ex. `R1.04`, `SAE2.01` (clé) |
| `semestre_id` | texte | semestre |
| `type` | texte | `ressource`, `sae`, `stage`, `portfolio` |
| `intitule` | texte | nom du module |
| `competence_code` | texte | compétence ciblée ; vide = transversal (projet personnel et professionnel) ou à compléter |
| `heures` | entier | volume horaire ; vide = à compléter |

Les volumes de S1 sont ceux des fiches nationales (300 h de ressources : 80 h C1, 105 h C2, 105 h C3, 10 h de projet personnel et professionnel). Les heures des SAÉ sont définies localement par l'IUT : elles se trouvent dans mon emploi du temps ou la maquette pédagogique de l'IUT de Dole.

### notes
| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `N001`… (clé) |
| `module_code` | texte | module concerné |
| `note` | réel 0 à 20 | note obtenue |
| `coefficient` | réel > 0 | coefficient de la note |
| `libelle_evaluation` | texte | ex. « Moyenne du module », « DS 1 » |

Pour ajouter une évaluation : copier une ligne, changer l'`id` et le `libelle_evaluation`, remplir la note et le coefficient, passer le statut à `ok`. Plusieurs évaluations par module sont possibles.

### technologies
| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `T01`… (clé) |
| `nom` | texte | nom affiché |
| `famille` | texte | `Langages`, `Données`, `Visualisation`, `Outils` |
| `niveau` | entier 1 à 5 | voir l'échelle ci-dessous ; vide = pas de barre affichée |

Échelle de niveau, à appliquer honnêtement (un employeur peut poser des questions dessus) : 1 notions · 2 débutant (cours + TP) · 3 à l'aise (utilisé seul dans au moins un projet) · 4 avancé (utilisé régulièrement, je peux l'expliquer) · 5 expert.

### projets
| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `P01`… (clé) |
| `titre`, `description` | texte | carte du projet |
| `categorie` | texte | `Académique`, `Personnel`, `Santé & secteur public` |
| `objectif`, `donnees_utilisees`, `difficultes` | texte | fenêtre de détail |
| `lien_code` | texte | URL du dépôt GitHub du projet |
| `visuel` | texte | chemin d'une image dans `app/static/img/` |

### projets_technologies
`projet_id` et `technologie_id` : une ligne par outil utilisé dans un projet.

### documents
| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `D01`… (clé) |
| `titre` | texte | nom affiché |
| `type` | texte | `CV`, `Attestations`, `Rapports` |
| `date` | texte | `AAAA-MM-JJ` |
| `fichier` | texte | chemin du fichier dans le dépôt |

## Ce que je dois encore saisir (par ordre d'importance pour le site)

1. `notes.csv` : mes notes et leurs coefficients (S1 à S4, puis S5 au fil de l'eau).
2. `semestres.csv` : statut de validation de S1 à S4 et moyennes officielles.
3. `modules.csv` : compétence et heures de chaque module à partir de S2.
4. `technologies.csv` : niveaux de chaque outil.
5. `projets.csv` : les autres projets, dont au moins un de la catégorie « Santé & secteur public ».
6. `documents.csv` : CV et attestations (fichiers à déposer dans le dépôt).
