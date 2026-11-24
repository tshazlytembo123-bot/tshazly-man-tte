# Dictionnaire des données et base des données 

qui doivent être completer diercement sous sql 

## Boutons 
créations des boutons permettant des d'accomplir des tâches demander 

## filtre 
créations des filtres permettant des switches directement dans des informations concerner des tâches demander 

## Colonne `statut`


| `ok` | ligne complète | oui |
| `a_valider` | remplie mais à relire (texte provisoire, niveau à définir…) | oui, signalée |
| `a_completer` | pas encore remplie | non (sauf `modules`, toujours chargés) |

## Sources et état de chaque fichier ( à modifier , imperativement base des données sql)


## Tables

### competences

| `code` | texte | `C1` à `C4` (clé) |
| `nom_court` | texte | Traiter, Analyser, Valoriser, Développer |
| `intitule` | texte | intitulé officiel |
| `description_courte` | texte | phrase affichée dans la carte |

### apprentissages_critiques

| `code` | texte | code officiel, ex. `AC11.01` (clé) |
| `competence_code` | texte | compétence rattachée |
| `niveau` | entier 1 à 3 | niveau de développement de la compétence (C4 : 1 à 2) |
| `intitule_niveau` | texte | ex. « Traiter des données structurées » |
| `libelle_court` | texte | formulation courte affichée dans le panneau de détail |

### semestres

| `id` | texte | `S1` à `S6` (clé) |
| `annee_but` | entier 1 à 3 | année de BUT |
| `annee_universitaire` | texte | ex. `2025-2026` |
| `heures_enseignement_nationales` | entier | volume national d'enseignement (ressources + SAÉ) |
| `heures_projet_tutore_nationales` | entier | volume national de projet tutoré |
| `stage_semaines_min`, `stage_semaines_max` | entier | fourchette nationale de stage |
| `statut_validation` | texte | `valide`, `en_cours`, `a_venir`, `a_saisir`, `non_valide` |
| `Resultats` | équivaut à 0 à 20 | moyenne du relevé, sert de contrôle |
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

### Resultats

| `id` | texte | `N001`… (clé) |
| `module_code` | texte | module concerné |
| `note` | réel 0 à 20 | note obtenue |
| `coefficient` | réel > 0 | coefficient de la note |
| `libelle_evaluation` | texte | ex. « Moyenne du module », « DS 1 » |

Pour ajouter une évaluation : copier une ligne, changer l'`id` et le `libelle_evaluation`, remplir la note et le coefficient, passer le statut à `ok`. Plusieurs évaluations par module sont possibles.

### externe

| `id` | texte | `T01`… (clé) |
| `nom` | texte | nom affiché |
| `famille` | texte | `Langages`, `Données`, `Visualisation`, `Outils` |
| `niveau` | entier 1 à 5 | voir l'échelle ci-dessous ; vide = pas de barre affichée |

Échelle de niveau, à appliquer honnêtement (un employeur peut poser des questions dessus) : 1 notions · 2 débutant (cours + TP) · 3 à l'aise (utilisé seul dans au moins un projet) · 4 avancé (utilisé régulièrement, je peux l'expliquer) · 5 expert.

### projets


| `id_sae` | texte | `P01`… (clé) |
| `titre`, `description` | texte | carte du projet |
| `categorie` | texte | `Académique`, `Personnel`, `Santé & secteur public` |
| `objectif`, `donnees_utilisees`, `difficultes` | texte | fenêtre de détail |
| `lien_code` | texte | URL du dépôt GitHub du projet |
| `visuel` | texte | chemin d'une image dans `html_site_web/img/` |

### projets_extern
`projet_id` et `externe_id` : une ligne par outil utilisé dans un projet.
`projet_nom` et `nom_externe`

### documents

| `id` | texte | `D01`… (clé) |
| `titre` | texte | nom affiché |
| `type` | texte | `CV`, `Attestations`, `Rapports` |
| `date` | texte | `AAAA-MM-JJ` |
| `fichier` | texte | chemin du fichier dans le dépôt |

## à faire directement sur la partie base des données donc en suivant le schemat relationnel de ma base des données et autres.

