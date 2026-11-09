# Projet de programmation web – Site de présentation de mes compétences

_Tshazly · BUT Science des Données (parcours VCOD) · IUT Besançon-Vesoul, site de Dole_

## Sujet et objectif

Ce projet est un site web qui met en valeur mes compétences, issues du BUT Science des Données et de mes expériences personnelles, auprès de futurs employeurs et de formations. Il présente mon parcours à travers des visualisations de données interactives. Mon objectif professionnel est de devenir Data Scientist, plus particulièrement dans les institutions publiques et le secteur médico-social.

## Données utilisées

- Mes résultats obtenus lors des projets et mon volume horaire par compétence et par semestre (source : mes relevés de notes ; fichiers `donnees/notes.csv`, `donnees/modules.csv`, `donnees/semestres.csv`)
- Les 4 compétences et 54 apprentissages critiques du BUT SD (source : programme national 2022, mis à jour en 2023 ; `donnees/competences.csv`, `donnees/apprentissages_critiques.csv`)
- Mes projets : titre, description, outils, lien vers le code (source : saisie manuelle, `donnees/projets.csv`)
- Mes technologies et mes documents (source : saisie manuelle, `donnees/technologies.csv`, `donnees/documents.csv`)

Chaque colonne est décrite dans `donnees/DICTIONNAIRE.md`.

## Fonctionnalités

- Navigation entre les sections : Accueil, Compétences, BUT SD, Notes, Projets, Documents (menu fixe, section active soulignée)
- Visualisation du volume horaire par compétence (filtre BUT 1 / 2 / 3)
- Visualisation de mes notes avec filtres par semestre et par module
- Présentation de mes projets avec filtre par catégorie et fenêtre de détail
- Accès à mon CV et à mes documents (filtre, téléchargement, aperçu)

## Technologies et bibliothèques

- Langages : HTML, CSS, JavaScript (site) ; Python (préparation des données)
- Bibliothèque de visualisation : Chart.js 4.4.1
- Base de données : SQLite (`data/portfolio.db`, reconstruite depuis les CSV)

## Lancer le projet

Je publie le site en public sur GitHub (GitHub Pages) et je travaille directement avec GitHub. Pour le tester en local :

```bash
git clone https://github.com/tshazlytembo123-bot/tshazly-man-tte.git
cd tshazly-man-tte
python scripts/charger_donnees.py   # valide les CSV et construit data/portfolio.db
python scripts/generer_site.py      # génère html_site_web/index.html à partir des CSV
python -m http.server 8000          # puis ouvrir http://localhost:8000/html_site_web/
```

## Organisation du dépôt

- `maquette/` : maquettes du site et leurs évolutions
- `donnees/` : jeux de données utilisés (CSV, schéma SQL, dictionnaire)
- `scripts/` : validation des CSV, base SQLite et génération du site
- `html_site_web/` : le site (`template.html`, `index.html` généré, dossier `img/`)
- `architecture/` : architecture générale (`ARCHITECTURE.md`)
- `Jeu_des_donnees/` : archive de la page de la base de données
- `choix_des_donnees.md` : choix des données
- `AVANCEMENT.md` : journal de bord et planning suivi au fil du projet

## Difficultés et limites connues

- Le temps de travail et la construction de ma maquette, qui change tout le temps.
- Notes, statuts de validation et niveaux des technologies restent à saisir (voir `donnees/DICTIONNAIRE.md`) : les graphiques correspondants sont vides tant que ce n'est pas fait.

## Contact

tshazlytembo123@gmail.com · [LinkedIn](https://www.linkedin.com/in/tshazly-tte-tembo) · [GitHub](https://github.com/tshazlytembo123-bot)
