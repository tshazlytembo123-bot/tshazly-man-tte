# Avancement du projet

Projet de programmation web : site de présentation de mes compétences
(BUT Science des Données, IUT Besançon-Vesoul, site de Dole).

## Planning prévisionnel

| Tâche | Prévu | État | Commentaire |
|---|---|---|---|
| Choix du sujet et des données | S41 (6/10) | Terminé | Voir `choix_des_donnees.md` |
| Initialisation du dépôt Git | S41 | Terminé | Dépôt public sur GitHub |
| README | S41 | Terminé | Mis à jour en S48 (installation et lancement) |
| Maquette du site | S41–S42 | En cours | À finaliser avant le TD2 |
| Architecture générale | S43 (23/10) | En cours | `architecture/ARCHITECTURE.md`, à valider après le TD2 |
| Préparation des données | S43–S47 | En cours | Schéma et données dans `donnees/`, notes à saisir |
| Partie serveur (base de données + contrôleur) | S48 (23/11) | En cours | Schéma, vues et contrôleur Express faits, routes à tester sur mon PostgreSQL |
| Visualisations | S48 (24/11) | En cours | `public/index.html` et `public/competences.html` |
| Interactions et filtres | S49 | En cours | Filtres, détail projet, aperçu documents faits |
| Tests et corrections | S49 | À faire | |
| Documentation | En continu | En cours | Finalisation en S49 |
| Préparation de l'oral | Semestre 6 | À faire | |

## Jalons

Début du projet → Choix des données → Maquette terminée → Première version fonctionnelle → Visualisations intégrées → Tests et corrections → Version finale

## Journal d'avancement

### Semaine S41 (6/10)
- Création du dépôt Git sur GitHub et passage en public
- Rédaction du README (sujet, données, fonctionnalités, instructions)
- Réalisation du premier planning prévisionnel
- Début de la maquette du site

### Semaine S43 (23/10)
- Architecture générale (`architecture/ARCHITECTURE.md`)
- Préparation des données (schéma SQL, dictionnaire)
- Partie serveur : base de données et contrôleur
- Visualisations, interactions et filtres : première version du site
- Tests et corrections, documentation en continu

### Semaine S48 (25/11)
- Mise en cohérence de l'ensemble : une seule base (PostgreSQL), un seul contrôleur (Node.js / Express), un seul jeu de données (`donnees/schema.sql` et `donnees/donnees.sql`)
- Suppression des doublons et des anciennes versions (CSV et scripts Python jamais livrés, copies des pages, des maquettes et du README)
- Le site charge toutes ses données depuis l'API ; le volume horaire vient désormais des activités pédagogiques réelles
- Documents personnels déplacés dans `prive/`, non publié

### Prochaines étapes
- Saisir mes notes, les statuts de validation des semestres et le niveau de chaque technologie dans `donnees/donnees.sql`
- Compléter les projets (objectif, données, difficultés, lien du code)
- Déposer la photo, les images de preuve et une version publique du CV (sans téléphone ni date de naissance)
- Finaliser la maquette (pages Accueil, Compétences, Notes, Projets, Documents)

## Difficultés rencontrées

- Définition du sujet et choix des données
- Plusieurs versions du projet en parallèle (Flask/SQLite sur le papier, Node.js/PostgreSQL dans le code), qui se contredisaient

## Modifications du planning et de la maquette

- Maquette en cours de construction (V1 du 06/10/2026 ; V2 = `public/`)
- Architecture : passage de Python/Flask/SQLite (V1) à Node.js/Express/PostgreSQL (V2), voir `architecture/ARCHITECTURE.md` § 2
##à faire
# Documents publics
avant de lancer de l'application
Les fichiers de ce dossier sont **accessibles à tous** depuis le site (adresse `/documents/<fichier>`).

N'y déposer que des documents sans numéro de téléphone, adresse, date de naissance ni numéro étudiant.
Pour publier le CV : déposer une version « publique » (sans téléphone ni date de naissance) sous le nom
`cv_tshazly.pdf`, puis passer `D02` à `'ok'` dans `donnees/donnees.sql` et lancer `npm run init`.
