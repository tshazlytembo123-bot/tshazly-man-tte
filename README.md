# Projet de programmation web – Site de présentation de mes compétences

_Tshazly · BUT Science des Données (parcours VCOD) · IUT Besançon-Vesoul, site de Dole_

## Sujet et objectif

Ce projet est un site web qui met en valeur mes compétences, issues du BUT Science des Données et de mes expériences personnelles, auprès de futurs employeurs et de formations. Il présente mon parcours à travers des visualisations de données interactives. Mon objectif professionnel est de devenir Data Scientist, plus particulièrement dans les institutions publiques et le secteur médico-social.

## Données utilisées

- Mes résultats et mon volume horaire par compétence et par semestre (source : mes relevés de notes et mon emploi du temps ; tables `NOTE`, `MODULE`, `SEMESTRE`, `ACTIVITE_PEDAGOGIQUE`)
- Les 4 compétences et 54 apprentissages critiques du BUT SD (source : programme national 2022, mis à jour en 2023 ; tables `COMPETENCE`, `APPRENTISSAGE_CRITIQUE`)
- Mes projets : titre, description, outils, lien vers le code (source : saisie manuelle ; tables `PROJET`, `PROJET_TECHNOLOGIE`)
- Mes technologies et mes documents (source : saisie manuelle ; tables `TECHNOLOGIE`, `DOCUMENT`)

La structure est dans `donnees/schema.sql`, les données dans `donnees/donnees.sql`, et chaque colonne est décrite dans `donnees/DICTIONNAIRE.md`.

## Fonctionnalités

- Navigation entre les sections : Accueil, Compétences, BUT SD, Notes, Projets, Documents (menu fixe, section active soulignée)
- Visualisation du volume horaire par compétence (filtre BUT 1 / 2 / 3), avec une page de détail par compétence : description, apprentissages critiques, preuves
- Visualisation de mes notes avec filtres par semestre et par module
- Présentation de mes projets avec filtre par catégorie et fenêtre de détail
- Accès à mon CV et à mes documents (filtre, téléchargement, aperçu)

## Technologies et bibliothèques

- Langages : HTML, CSS, JavaScript (site) ; Node.js (serveur) ; SQL (base)
- Serveur : Express 4 ; accès à la base : `pg`
- Base de données : PostgreSQL (base `butsd`)
- Bibliothèque de visualisation : Chart.js 4.4.1

## Lancer le projet

Prérequis : Node.js 18 ou plus et un serveur PostgreSQL local qui tourne (utilisateur `postgres` par défaut).

```bash
git clone https://github.com/tshazlytembo123-bot/tshazly-man-tte.git
cd tshazly-man-tte
npm install          
npm run init         
npm start            
```

- Si l'utilisateur ou le mot de passe de PostgreSQL ne sont pas ceux par défaut, les régler avant `npm run init` et `npm start` avec les variables `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` ou `DATABASE_URL` (voir `.env.example`).
- Après chaque modification de `donnees/donnees.sql` (nouvelles notes, niveaux des technologies…), relancer `npm run init`.
- Page de détail des compétences : <http://localhost:3000/competences.html>. Vérification du serveur : <http://localhost:3000/api/sante>.

Un site avec un serveur et une base de données ne peut pas être publié sur GitHub Pages : voir `architecture/ARCHITECTURE.md` § 11.

## Organisation du dépôt

- `serveur/` : contrôleur Express (`server.js`)
- `public/` : le site (`index.html`, `competences.html`, dossier `img/`)
- `donnees/` : schéma SQL, données et dictionnaire
- `preuves/` : images de preuve des apprentissages critiques
- `maquette/` : maquettes du site et leurs évolutions
- `documents/` : documents publics téléchargeables depuis le site
- `prive/` : documents personnels (CV complet, lettre de motivation), jamais publiés (voir `.gitignore`)
- `architecture/` : architecture générale (`ARCHITECTURE.md`)
- `choix_des_donnees.md` : choix des données
- `AVANCEMENT.md` : journal de bord et planning suivi au fil du projet

## Difficultés et limites connues

- Le temps de travail et la construction de ma maquette, qui change tout le temps.
- Notes, statuts de validation des semestres et niveaux des technologies restent à saisir dans `donnees/donnees.sql` (voir `donnees/DICTIONNAIRE.md`) : les graphiques correspondants sont vides tant que ce n'est pas fait.
- Les images de preuve (`preuves/`) et la photo (`public/img/photo.jpg`) restent à déposer.

## Contact

tshazlytembo123@gmail.com · [LinkedIn](https://www.linkedin.com/in/tshazly-tte-tembo) · [GitHub](https://github.com/tshazlytembo123-bot)
