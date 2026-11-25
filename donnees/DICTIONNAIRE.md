# Dictionnaire des données

Les données vivent dans la base PostgreSQL `butsd`. Leur source de vérité est le couple de fichiers de ce dossier :

- `schema.sql` : structure (tables, contraintes, vues) ;
- `donnees.sql` : les données, à compléter directement dans ce fichier.

Après chaque modification, lancer `npm run init` : la base est reconstruite en une seule transaction (si une ligne est incohérente, rien n'est modifié et PostgreSQL indique l'erreur).

## Colonne `statut`

Présente dans `MODULE`, `NOTE`, `TECHNOLOGIE`, `PROJET` et `DOCUMENT`.

| Valeur | Sens | Publié sur le site ? |
|---|---|---|
| `ok` | ligne complète | oui |
| `a_valider` | remplie mais à relire (texte provisoire, niveau à définir…) | oui |
| `a_completer` | pas encore remplie | non (sauf `MODULE`, toujours chargé). Pour un document, le chemin du fichier n'est jamais envoyé au navigateur |

## Tables

### COMPETENCE

| Colonne | Type | Description |
|---|---|---|
| `id_competence` | texte (2) | `C1` à `C4` (clé) |
| `nom_court` | texte | Traiter, Analyser, Valoriser, Développer |
| `intitule` | texte | intitulé officiel |
| `description` | texte | composantes essentielles (texte officiel), une par ligne |
| `description_courte` | texte | phrase affichée dans la carte |

### ANNEE

| Colonne | Type | Description |
|---|---|---|
| `id_annee` | texte (4) | `BUT1`, `BUT2`, `BUT3` (clé) |
| `intitule` | texte | niveaux de développement des compétences de l'année |

### SEMESTRE

| Colonne | Type | Description |
|---|---|---|
| `num` | entier 1 à 6 | numéro du semestre (clé) ; affiché `S1` à `S6` |
| `id_annee` | texte | année de BUT (clé étrangère vers `ANNEE`) |
| `annee_universitaire` | texte | ex. `2025-2026` |
| `heures_enseignement_nationales` | entier | volume national d'enseignement (ressources + SAÉ) |
| `heures_projet_tutore_nationales` | entier | volume national de projet tutoré |
| `stage_semaines_min`, `stage_semaines_max` | entier | fourchette nationale de stage |
| `statut_validation` | texte | `valide`, `en_cours`, `a_venir`, `a_saisir`, `non_valide` |
| `moyenne_officielle` | réel 0 à 20 | moyenne du relevé ; sert de contrôle et alimente la courbe quand il n'y a pas de notes détaillées |
| `commentaire` | texte | libre |

### APPRENTISSAGE_CRITIQUE

| Colonne | Type | Description |
|---|---|---|
| `id_ac` | texte | code officiel, ex. `AC11.01`, `AC24.02VCOD` (clé) |
| `id_annee` | texte | année de BUT |
| `id_competence` | texte | compétence rattachée (4e caractère du code : `AC1`**`1`**`.01` → C1) |
| `niveau` | entier 1 à 3 | niveau de développement de la compétence (C4 : 1 à 2) |
| `intitule_niveau` | texte | ex. « Traiter des données structurées » |
| `libelle_court` | texte | formulation courte affichée dans le panneau de détail |
| `intitule` | texte | formulation officielle complète |

### ACTIVITE_PEDAGOGIQUE

Une ligne par activité de mon emploi du temps. C'est la source du volume horaire par compétence.

| Colonne | Type | Description |
|---|---|---|
| `num` | entier | numéro automatique (clé) |
| `semestre` | entier 1 à 6 | semestre (clé étrangère vers `SEMESTRE`) |
| `heure` | entier > 0 | durée en heures |
| `skill` | texte | intitulé de l'activité |
| `id_competence` | texte | compétence ciblée |

### PREUVE

| Colonne | Type | Description |
|---|---|---|
| `id_preuve` | entier | numéro automatique (clé) |
| `id_ac` | texte | apprentissage critique prouvé |
| `fichier` | texte | nom d'une image du dossier `preuves/` |

### MODULE

| Colonne | Type | Description |
|---|---|---|
| `code` | texte | ex. `R1.04`, `SAE2.01` (clé) |
| `semestre` | entier 1 à 6 | semestre |
| `type` | texte | `ressource`, `sae`, `stage`, `portfolio` |
| `intitule` | texte | nom du module |
| `id_competence` | texte | compétence ciblée ; vide = transversal (projet personnel et professionnel) ou à compléter |
| `statut` | texte | voir plus haut |

Les heures ne sont pas portées par `MODULE` : elles viennent de `ACTIVITE_PEDAGOGIQUE`.

### NOTE

| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `N001`… (clé) |
| `code_module` | texte | module concerné |
| `note` | réel 0 à 20 | note obtenue |
| `coefficient` | réel > 0 | coefficient de la note (1 par défaut) |
| `libelle_evaluation` | texte | ex. « Moyenne du module », « DS 1 » |
| `statut` | texte | voir plus haut |

Pour ajouter une évaluation : décommenter l'exemple dans `donnees.sql` (section « Notes »), changer l'`id`, le module, la note et le coefficient, puis lancer `npm run init`. Plusieurs évaluations par module sont possibles.

### TECHNOLOGIE

| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `T01`… (clé) |
| `nom` | texte | nom affiché (unique) |
| `famille` | texte | `Langages`, `Données`, `Visualisation`, `Outils` |
| `niveau` | entier 1 à 5 | voir l'échelle ci-dessous ; vide = « Niveau à définir » |
| `statut` | texte | voir plus haut |

Échelle de niveau, à appliquer honnêtement (un employeur peut poser des questions dessus) : 1 notions · 2 débutant (cours + TP) · 3 à l'aise (utilisé seul dans au moins un projet) · 4 avancé (utilisé régulièrement, je peux l'expliquer) · 5 expert.

### PROJET

| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `P01`… (clé) |
| `titre`, `description` | texte | carte du projet |
| `categorie` | texte | `Académique`, `Personnel`, `Santé & secteur public` |
| `objectif`, `donnees_utilisees`, `difficultes` | texte | fenêtre de détail |
| `lien_code` | texte | URL du dépôt GitHub du projet |
| `visuel` | texte | chemin d'une image de `public/img/`, ex. `img/p01.png` |
| `statut` | texte | voir plus haut |

### PROJET_TECHNOLOGIE

`id_projet` et `id_technologie` : une ligne par outil utilisé dans un projet (clé composée).

### DOCUMENT

| Colonne | Type | Description |
|---|---|---|
| `id` | texte | `D01`… (clé) |
| `titre` | texte | nom affiché |
| `type` | texte | `CV`, `Attestations`, `Rapports` |
| `date` | date | `AAAA-MM-JJ` |
| `fichier` | texte | chemin relatif au site : `maquette/…` ou `documents/…` |
| `statut` | texte | voir plus haut |

Le CV (`D02`) reste à `a_completer` tant qu'une version publique n'est pas déposée dans `documents/` : le CV complet contient un numéro de téléphone et une date de naissance et reste dans `prive/`.

## Vues SQL (créées par `schema.sql`)

| Vue | Rôle |
|---|---|
| `v_notes_detail` | une ligne par note, avec module, compétence, semestre et année |
| `v_notes_tranche` | ajoute la tranche de la note (`<8`, `8-10`, `10-12`, `12-14`, `>14`) |
| `v_moyenne_semestre` | moyenne pondérée par semestre (courbe de progression) |
| `v_volume_horaire` | heures par année, semestre et compétence (graphique en barres) |
| `v_kpi_accueil` | les quatre compteurs de l'accueil |
