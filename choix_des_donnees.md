# Choix des données

Les données du site sont rangées dans la base PostgreSQL, dont le contenu est écrit dans `donnees/donnees.sql` (voir `donnees/DICTIONNAIRE.md`) :

- **Parcours BUT SD** : compétences, apprentissages critiques, semestres et modules (programme national).
- **Résultats** : mes notes et leurs coefficients, issues de mes relevés (table `NOTE`). Elles alimentent les graphes qui représentent l'acquisition de chaque matière. Les notes ne sont publiées que si leur statut n'est pas `a_completer`.
- **Volume horaire** : heures par activité de mon emploi du temps, rattachées à une compétence et à un semestre (table `ACTIVITE_PEDAGOGIQUE`).
- **Technologies** : outils et langages avec un niveau honnête de 1 à 5 (table `TECHNOLOGIE`).
- **Projets** et **documents** : saisie manuelle (tables `PROJET` et `DOCUMENT`).
