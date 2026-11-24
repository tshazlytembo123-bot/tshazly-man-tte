-- ============================================================
-- 1. NETTOYAGE
-- ============================================================
DROP TABLE IF EXISTS LISTE_AC CASCADE;
DROP TABLE IF EXISTS PREUVE CASCADE;
DROP TABLE IF EXISTS ACTIVITE_PEDAGOGIQUE CASCADE;
DROP TABLE IF EXISTS APPRENTISSAGE_CRITIQUE CASCADE;
DROP TABLE IF EXISTS COMPETENCE CASCADE;
DROP TABLE IF EXISTS ANNEE CASCADE;

-- ============================================================
-- 2. CRÉATION DES TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS COMPETENCE (
    id_competence CHAR(2) PRIMARY KEY,
    intitule TEXT NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ANNEE (
    id_annee CHAR(4) PRIMARY KEY,
    intitule TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ACTIVITE_PEDAGOGIQUE (
    num SERIAL PRIMARY KEY,
    semestre INT NOT NULL,
    heure INT NOT NULL,
    skill TEXT NOT NULL,
    id_competence CHAR(2) NOT NULL,
    FOREIGN KEY (id_competence) REFERENCES COMPETENCE(id_competence)
);

CREATE TABLE IF NOT EXISTS APPRENTISSAGE_CRITIQUE (
    id_ac VARCHAR(12) PRIMARY KEY,
    intitule TEXT NOT NULL,
    id_annee CHAR(4) NOT NULL,
    niveau INT,
    id_competence CHAR(2),
    FOREIGN KEY (id_annee) REFERENCES ANNEE(id_annee),
    FOREIGN KEY (id_competence) REFERENCES COMPETENCE(id_competence)
);

CREATE TABLE IF NOT EXISTS PREUVE (
    id_preuve SERIAL PRIMARY KEY,
    id_ac VARCHAR(12) NOT NULL,
    fichier TEXT NOT NULL,
    FOREIGN KEY (id_ac) REFERENCES APPRENTISSAGE_CRITIQUE(id_ac) ON DELETE CASCADE
);

-- ============================================================
-- 3. INSERTION DES DONNÉES DE BASE
-- ============================================================

INSERT INTO ANNEE (id_annee, intitule) VALUES
('BUT1', '1ère année BUT Science des Données'),
('BUT2', '2ème année BUT Science des Données'),
('BUT3', '3ème année BUT Science des Données');

INSERT INTO COMPETENCE (id_competence, intitule, description) VALUES
('C1', 'Traiter des données à des fins décisionnelles', $$Collecte, nettoyage, préparation et stockage des données (SQL, NoSQL, Big Data).$$),
('C2', 'Analyser statistiquement les données', $$Exploration, modélisation statistique et Intelligence Artificielle (Machine Learning).$$),
('C3', 'Valoriser une production dans un contexte professionnel', $$Visualisation de données (Dataviz), reporting, communication et contexte gestionnaire.$$),
('C4', 'Développer un outil décisionnel', $$Développement d'applications, programmation web et automatisation des traitements.$$);

-- ============================================================
-- 4. INSERTION DES APPRENTISSAGES CRITIQUES (COMPLETE)
-- ============================================================

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
-- BUT1
('AC11.01', 'Interpréter le besoin du client', 'BUT1'),
('AC11.02', 'Respecter les formalismes', 'BUT1'),
('AC11.03', 'Utiliser la syntaxe des langages', 'BUT1'),
('AC11.04', 'Maîtriser la structure des données', 'BUT1'),
('AC11.05', 'Comprendre les algorithmes de base', 'BUT1'),
('AC12.01', 'Identifier les sources de données', 'BUT1'),
('AC12.02', 'Préparer les données', 'BUT1'),
('AC12.03', 'Utiliser des synthèses statistiques', 'BUT1'),
('AC13.01', 'Identifier les biais d’une enquête', 'BUT1'),
('AC13.02', 'Contextualiser les données', 'BUT1'),
('AC13.05', 'Comprendre la Dataviz', 'BUT1'),

-- BUT2 
('AC21.01', 'Comprendre les données de l''entreprise', 'BUT2'),
('AC21.02', 'Rôle de l''entrepôt de données', 'BUT2'),
('AC21.03', 'Intégrer des sources complémentaires', 'BUT2'),
('AC21.04', 'Tester et documenter un programme', 'BUT2'),
('AC22.01', 'Modélisation statistique vs exploratoire', 'BUT2'),
('AC22.03', 'Analyses multivariées', 'BUT2'),
('AC23.03', 'Choisir des indicateurs pertinents', 'BUT2'),
('AC24.01VCOD', 'Analyser des besoins', 'BUT2'),
('AC24.02VCOD', 'Automatiser des tâches', 'BUT2'),
('AC24.04VCOD', 'Cycle de vie d’un projet', 'BUT2'),

-- BUT3
('AC31.01', 'Architecture Big Data', 'BUT3'),
('AC31.02', 'Exploiter données complexes', 'BUT3'),
('AC31.03', 'Mener une veille technologique', 'BUT3'),
('AC32.04', 'Comprendre l’IA et le Machine Learning', 'BUT3'),
('AC33.01', 'Transformer la donnée (anonymisation)', 'BUT3'),
('AC33.03', 'Communiquer efficacement', 'BUT3'),
('AC34.01VCOD', 'Utiliser des moyens spécifiques', 'BUT3'),
('AC34.02VCOD', 'Argumenter ses choix de solution', 'BUT3'),
('AC34.03VCOD', 'Appliquer des méthodes de développement', 'BUT3'),
('AC34.04VCOD', 'Utiliser un gestionnaire de versions (Git)', 'BUT3');

UPDATE APPRENTISSAGE_CRITIQUE 
SET id_competence = 'C' || SUBSTRING(id_ac FROM 4 FOR 1);

-- ============================================================
-- 5. INSERTION DES COURS
-- ============================================================

INSERT INTO ACTIVITE_PEDAGOGIQUE (semestre, heure, skill, id_competence) VALUES
-- SEMESTRE 1
(1, 15, 'Etude données envt ent & éco (intro marketing)', 'C3'),
(1, 22, 'Base de données relationnelles 1', 'C1'),
(1, 40, 'Statistique descriptive 1', 'C2'),
(1, 19, 'Bases de la programmation 2', 'C4'),
(1, 4, 's1 Analyse des données d''une enquete', 'C2'),
(1, 15, 'Bases de l''algèbre', 'C2'),
(1, 22, 'Probabilités 1', 'C2'),
(1, 15, 'Bases de la programmation 1', 'C4'),
(1, 38, 'Découverte données entrepreunarial et économique', 'C3'),
(1, 6, 'Statistique descriptive 1 (TP)', 'C2'),
(1, 7, 'PPP - tutorat 1P', 'C3'),
(1, 4, 'Projet Personnel et Professionnel 1', 'C3'),
(1, 1, 'Bases de l''algèbre', 'C2'),
(1, 3, 'Probabilités 1 (machine)', 'C2'),
(1, 5, 'Bases de la programmation 1', 'C4'),
(1, 4, 'Statistique descriptive 1', 'C2'),
(1, 10, 'Bases de la programmation 1 (TP)', 'C4'),
(1, 8, 'Base de données relationnelles 1 (TP)', 'C1'),
(1, 4, 'Probabilités 1', 'C2'),
(1, 6, 's1 Communication de l''information : l''enquête', 'C3'),
(1, 2, 'Découverte données entrepreunarial et économique', 'C3'),
(1, 7, 'Projet Personnel et Professionnel 1 (autonomie)', 'C3'),
(1, 8, 's1 Communication de l''information et recherche documentaire', 'C3'),
(1, 6, 'Bases de la programmation 2 (TP)', 'C4'),
(1, 2, 'Projet Personnel et Professionnel 1 : fiches métiers', 'C3'),
(1, 2, 'Bases de la programmation 2', 'C4'),
(1, 6, 'Découverte données entrepreunarial et économique (autonomie)', 'C3'),
(1, 2, 'Bases de la programmation 1 (CJ)', 'C4'),
(1, 12, 'Tableur et reporting', 'C3'),
(1, 4, 'Analyse des données d''une enquete (projet)', 'C2'),
(1, 26, 'Mathématiques - Analyse (CJ)', 'C2'),
(1, 28, 'Statistique inférentielle', 'C2'),
(1, 7, 'Régression sur données réelles', 'C2'),
(1, 5, 'Ecriture et lecture de fichiers de données', 'C1'),
(1, 8, 'Reporting et datavisualisation CF', 'C3'),
(1, 2, 'dataviz rentrée', 'C3'),
(1, 8, 'Estimation par échantillonnage', 'C2'),
(1, 8, 'Communication et sémiologie - Suite office', 'C3'),
(1, 2, 'dataviz rentrée restit', 'C3'),
(1, 9, 'Analyse des données d''une enquete', 'C2'),
(1, 6, 'Ecriture et lecture de fichiers de données (non encadré)', 'C1'),
(1, 3, 'Reporting données stockées dans SGBD relationnel (projet)', 'C3'),
(1, 7, 'Mathématiques - Analyse (CF)', 'C2'),
(1, 12, 'Mathématiques - Analyse (DC)', 'C2'),
(1, 4, 'Mathématiques - Analyse (TP)', 'C2'),
(1, 16, 'Communication et sémiologie', 'C3'),
(1, 10, 'Tableur et reporting (TP)', 'C3'),
(1, 3, 'Analyse de données reporting et datavisualisation (restitution)', 'C3'),
(1, 9, 'Conception et implémentation d''une base de données (non encadré)', 'C1'),
(1, 9, 'Datavisualisation', 'C3'),
(1, 2, 'Préparation et synthèse tableau de données pour analyse (lancemen t)', 'C1'),
(1, 20, 'Apprendre en situation la prod°de données en entreprise', 'C3'),
(1, 6, 'Energie - environnement (POL)', 'C3'),
(1, 19, 'Communication de l''information et recherche documentaire (A.Morea ux)', 'C3'),
(1, 6, 'Programmation statistique (VBA)', 'C4'),
(1, 3, 'Apprendre en situation la prod°de données en entreprise (autonomi e)', 'C3'),
(1, 1, 'Méthodologie du travail universitaire', 'C3'),
(1, 3, 'Conférence métier (INSEE stat)', 'C3'),
(1, 2, 'PPP2 : Le métier d''Enseigant-Chercheur', 'C3'),
(1, 1, 'Présentation alternance (par mme Joly)', 'C3'),
(1, 3, 'Présentation en anglais territoire economique culturel', 'C3'),
(1, 3, 'Reporting et datavisualisation CJ', 'C3'),
(1, 2, 'rentrée PEC SD', 'C3'),
(1, 3, 'Présentation en anglais territoire économique culturel', 'C3'),

-- SEMESTRE 2
(2, 4, 'Projet Personnel et Professionnel 2 (autonomie)', 'C3'),
(2, 8, 'Statistique descriptive 2', 'C2'),
(2, 21, 'Probabilités 2', 'C2'),
(2, 2, 'Statistique descriptive 2', 'C2'),
(2, 22, 'Approfondissement de l''anglais de spécialité', 'C3'),
(2, 2, 'Ecriture et lecture de fichiers de données (soutenances)', 'C1'),
(2, 2, 'Projet Personnel et Professionnel 2', 'C3'),
(2, 16, 'Base de données relationnelles 2', 'C1'),
(2, 6, 'Portfolio (soutenance)', 'C3'),
(2, 6, 'Soutenances PPP S2', 'C3'),
(2, 6, 'Probabilités 2 - simulation', 'C2'),
(2, 6, 'Base de données relationnelles 2 (TP)', 'C1'),
(2, 8, 'Participation aux soutenances', 'C3'),
(2, 2, 'Base de données relationnelles 2', 'C1'),
(2, 1, 'PPP - tutorat 2P', 'C3'),
(2, 3, 'Analyse de données reporting et datavisualisation (soutenance mét ier)', 'C3'),
(2, 4, 'Analyse de données reporting et datavisualisation (soutenance tec hnique)', 'C3'),
(2, 2, 'Probabilités 2', 'C2'),
(2, 93, 'Analyse de données reporting et datavisualisation (Non encadré)', 'C3'),
(2, 7, 'Portfolio (autonomie)', 'C3'),
(2, 32, 'Etude données environnement entrepreunarial & écononique', 'C3'),
(2, 12, 'Analyse de données reporting et datavisualisation (CdP)', 'C3'),
(2, 3, 'Energie - environnement', 'C3'),
(2, 10, 'Conception et implémentation d''une base de données', 'C1'),
(2, 8, 'enquête - administration terrain', 'C3'),
(2, 9, 'Reporting données stockées dans SGBD relationnel (projet)', 'C3'),
(2, 8, 'Analyse de données reporting et datavisualisation (tutorat CJ)', 'C3'),
(2, 14, 'Mise en oeuvre d''une enquête - projet non encadré', 'C2'),
(2, 6, 'Préparation et synthèse tableau de données pour analyse', 'C1'),
(2, 5, 'Programmation statistique (R TD)', 'C4'),
(2, 25, 'Anglais de spécialité', 'C3'),
(2, 10, 'Portfolio (non encadré)', 'C3'),
(2, 6, 'Programmation statistique (QGIS)', 'C4'),
(2, 8, 'Reporting et datavisualisation CJ TP', 'C3'),
(2, 12, 'Analyse des données d''une enquete (non encadré)', 'C2'),
(2, 4, 'PPP1 Presentation', 'C3'),
(2, 10, 'Mise en oeuvre d''une enquête', 'C2'),
(2, 7, 'Mise en oeuvre d''une enquête - projet', 'C2'),
(2, 2, 'Cours Moodle : Être étudiant\, ça s''apprend', 'C3'),
(2, 1, 'Estimation par échantillonnage (projet)', 'C2'),
(2, 10, 'Journées portes ouvertes Dole', 'C3'),
(2, 12, 'Analyse de données reporting et datavisualisation (tutorat)', 'C3'),
(2, 3, 'Présentation en anglais territoire economique culturel', 'C3'),
(2, 12, 'Construction et présentation d''indicateurs de performance', 'C3'),
(2, 2, 'Ecriture et lecture de fichiers de données (projet)', 'C1'),
(2, 4, 'Conférence métier (BD issus de capteurs)', 'C3'),
(2, 5, 'Alternance dating', 'C3'),
(2, 8, 'Communication et sémiologie - image de marque', 'C3'),
(2, 4, 'Communication et sémiologie TP', 'C3'),
(2, 5, 'Portfolio', 'C3'),
(2, 5, 'Reporting données stockées dans SGBD relationnel', 'C3'),
(2, 4, 'Programmation statistique (VBA)', 'C4'),
(2, 4, 'Analyse de données reporting et datavisualisation (rapport)', 'C3'),
(2, 1, 'Préparation et synthèse tableau de données pour analyse (projet)', 'C1'),
(2, 1, 'Mathématiques - Analyse (CJ)', 'C2'),
(2, 3, 'Fresque du climat', 'C3'),
(2, 1, 'Reporting et datavisualisation CF', 'C3'),
(2, 3, 'Conception et implémentation d''une base de données (projet)', 'C1'),
(2, 4, 'Programmation statistique (R TP)', 'C4'),
(2, 1, 'Conseil de département', 'C3'),
(2, 1, 'Prog - bonnes pratiques', 'C4'),
(2, 3, 'Préparation et synthèse tableau de données pour analyse', 'C1'),
(2, 2, 'Energie - environnement (POL)', 'C3'),
(2, 2, 'Apprendre en situation la prod°de données en entreprise (projet)', 'C3'),
(2, 2, 'Estimation par échantillonnage (non encadré)', 'C2'),
(2, 3, 'Communication de l''information et recherche documentaire', 'C3'),
(2, 2, 'retard ouverture gymnase', 'C3'),
(2, 2, 'Préparation et synthèse tableau de données pour analyse', 'C1'),
(2, 5, 'Dolesup', 'C3'),
(2, 2, 'dataviz rentrée (avec S3)', 'C3'),
(2, 2, 'Statistique inférentielle', 'C2'),
(2, 2, 'Mathématiques - Analyse (CF)', 'C2'),
(2, 2, 'Tableur et reporting', 'C3'),

-- SEMESTRE 3
(3, 24, 'SAÉ 3.03 - Description et prévision de données temporelles', 'C2'),
(3, 28, 's3 Communication organisationnelle et professionnelle', 'C3'),
(3, 12, 'SAÉ 3.01 - Collecte automatisée de données web (Autonomie)', 'C4'),
(3, 6, 'SAÉ 3.02 - Intégration de données dans un Datawarehouse (projet)', 'C1'),
(3, 3, 'SAÉ 3.01 - Collecte automatisée de données web (projet CJ)', 'C4'),
(3, 12, 'SAÉ 3.01 - Collecte automatisée de données web (CJ)', 'C4'),
(3, 3, 'SAÉ 3.01 - Collecte automatisée de données web (projet DT)', 'C4'),
(3, 12, 'SAÉ 3.01 - Collecte automatisée de données web (DT)', 'C4'),
(3, 20, 'SAÉ 3.02 - Intégration de données dans un Datawarehouse', 'C1'),
(3, 6, 'Introduction aux techniques de sondage', 'C2'),
(3, 18, 'SAÉ 3.02 - Intégration de données dans un Datawarehouse (autonomi e)', 'C1'),
(3, 2, 'dataviz rentrée (avec S3)', 'C3'),
(3, 12, 'Introduction à la cybersécurité des données', 'C1'),
(3, 12, 'Introduction aux données textuelles', 'C2'),
(3, 17, 'SAÉ 3.04 - Conformité réglementaire pour traiter des données', 'C1'),
(3, 1, 'Introduction aux techniques de sondage - test', 'C2'),
(3, 2, 'Technologie web', 'C4'),
(3, 10, 'Anglais scientifique et argumentation', 'C3'),
(3, 28, 'Sport', 'C3'),
(3, 10, 'Technologie web', 'C4'),
(3, 20, 'Algèbre linéaire', 'C2'),
(3, 12, 'Exploration et valorisation de la donnée cadre juridique/éco', 'C3'),
(3, 13, 'Automatisation et test', 'C4'),
(3, 12, 'Classification automatique', 'C2'),
(3, 2, 'Données de l''environnement (autonomie)', 'C3'),
(3, 6, 'Programmation objet (projet autonomie)', 'C4'),
(3, 22, 'Test d''hypothèses pour analyse bi-variée', 'C2'),
(3, 4, 'Projet personnel et professionnel : PE', 'C3'),
(3, 3, 'Projet personnel et professionnel : connaissance de soi', 'C3'),
(3, 2, 'dataviz rentrée restit', 'C3'),
(3, 8, 'Projet personnel et professionnel : Posture professionnelle', 'C3'),
(3, 8, 'Explor. et valor. cadre juridique/éco - partie RSE', 'C3'),
(3, 10, 'Journées portes ouvertes Dole', 'C3'),
(3, 1, 'rentrée PEC SD', 'C3'),
(3, 6, 'Projet personnel et professionnel', 'C3'),
(3, 2, 'Méthodes factorielles', 'C2'),
(3, 6, 'Automatisation et test (projet)', 'C4'),
(3, 13, 'Système d''information géographique', 'C3'),

-- SEMESTRE 4
(4, 10, 'SAÉ 4.02 - Reporting d''une analyse multivariée (autonomie)', 'C3'),
(4, 7, 'SAÉ 4.01 - Développement composant solution décisionnelle (projet )', 'C4'),
(4, 4, 'Programmation statistique avancée (projet autonomie)', 'C4'),
(4, 18, 'Utilisation d''outils de reporting 2', 'C3'),
(4, 16, 'Utilisation avancée d''outils de reporting', 'C3'),
(4, 11, 'SAÉ 4.02 - Reporting d''une analyse multivariée (ACM)', 'C3'),
(4, 9, 'SAÉ 4.02 - Reporting d''une analyse multivariée (RShiny)', 'C3'),
(4, 2, 'Programmation statistique avancée (projet)', 'C4'),
(4, 2, 'SAÉ 4.02 - Reporting d''une analyse multivariée (ACM)', 'C3'),
(4, 18, 'Programmation statistique avancée', 'C4'),
(4, 3, 'Projet personnel et professionnel : soutenance', 'C3'),
(4, 3, 'SAÉ 4.02 - Reporting d''une analyse multivariée (projet CJ)', 'C3'),
(4, 3, 'soutenances PPP s4', 'C3'),
(4, 27, 'SAÉ 4.01 - Développement composant solution décisionnelle (autono mie)', 'C4'),
(4, 8, 'soutenances alternance', 'C3'),
(4, 6, 'SAÉ 4.01 - Développement composant solution décisionnelle', 'C4'),
(4, 4, 'Portfolio s4', 'C3'),
(4, 4, 'soutenances Portfolio s4', 'C3'),
(4, 2, 'SAÉ 4.01 - Développement composant solution décisionnelle (souten ance)', 'C4'),
(4, 20, 'Programmation objet', 'C4'),
(4, 4, 'Portfolio', 'C3'),
(4, 31, 'Données de l''environnement entreprena et éco pour aide décis', 'C1'),
(4, 24, 'Anglais professionnel', 'C3'),
(4, 20, 'Systèmes d''information décisionnels', 'C4'),
(4, 3, 'Portfolio (autonomie)', 'C3'),
(4, 16, 'Méthodes factorielles', 'C2'),
(4, 16, 'Préparation / Intégration de données', 'C1'),
(4, 8, 'Communication scientifique et argumentation', 'C3'),
(4, 4, 'Projet personnel et professionnel : IA génératives', 'C2'),
(4, 6, 'Classification automatique (compléments)', 'C2'),
(4, 10, 'Droit', 'C3'),
(4, 12, 'Programmation web', 'C4'),
(4, 2, 'Programmation objet (projet)', 'C4'),
(4, 2, 'Présentation règles de l''alternance', 'C3'),
(4, 2, 'Test d''hypothèses pour analyse bi-variée', 'C2'),
(4, 4, 'Mon alternance en anglais', 'C3'),
(4, 1, 'Conseil de département', 'C3'),
(4, 2, 'Test d''hypothèses pour analyse bi-variée', 'C2'),

-- SEMESTRE 5
(5, 12, 'SAÉ 5.01 - Analyse et conception d''un outil décisionnel', 'C4'),
(5, 7, 'SAÉ 5.01 - Analyse et conception d''un outil décisionnel (projet)', 'C4'),
(5, 14, 'SAÉ 5.01 - Analyse et conception d''un outil décisionnel JA', 'C4'),
(5, 12, 'SAÉ 5.02 - Migration NoSQL', 'C1'),
(5, 21, 'SAÉ 5.01 - Analyse et conception d''un outil décisionnel (projet a utonomie)', 'C4'),
(5, 12, 'SAÉ 5.03 - Datamining', 'C2'),
(5, 15, 's5 Communication des données', 'C3'),
(5, 18, 'Traitement des données textuelles', 'C2'),
(5, 20, 'Méthodes statistiques pour le big data', 'C2'),
(5, 10, 'Anglais pour la communication d''entreprise', 'C3'),
(5, 20, 'Big Data : enjeux\, stockage et extraction', 'C1'),
(5, 24, 'Développement logiciel', 'C4'),
(5, 15, 'base de données NoSQL DT', 'C1'),
(5, 6, 'Classification de données textuelles', 'C2'),
(5, 2, 'base de données NoSQL CJ', 'C1'),
(5, 12, 'Apprentissage automatique pour l''IA', 'C2'),
(5, 8, 'Projet personnel et professionnel', 'C3'),
(5, 3, 'Data Mining', 'C2'),
(5, 3, 'Portfolio (autonomie)', 'C3'),
(5, 10, 'Communication pour le management', 'C3'),
(5, 1, 'Conseil de département', 'C3'),
(5, 6, 'Data Mining (MS)', 'C2'),

-- SEMESTRE 6
(6, 28, 'SAÉ 6.01 - Développement et test d''un outil décisionnel', 'C4'),
(6, 8, 'SAÉ 6.01 - Développement et test d''un outil décisionnel (projet)', 'C4'),
(6, 12, 'Applications en économie et gestion 2', 'C3'),
(6, 22, 'SAÉ 6.01 - Développement et test d''un outil décisionnel (projet a utonomie))', 'C4'),
(6, 30, 'Approfondissement en Big Data', 'C1'),
(6, 8, 'soutenances alternance', 'C3'),
(6, 8, 'soutenances stage BUT2 / ALT BUT3', 'C3'),
(6, 1, 'soutenances Portfolio s6 FI', 'C3'),
(6, 12, 'Anglais de spécialité (MC)', 'C3'),
(6, 16, 'Data Mining', 'C2'),
(6, 2, 'rentrée PEC SD', 'C3'),
(6, 30, 'Programmation web pour la visualisation', 'C4'),
(6, 10, 'Classification automatique (Réseaux de neurones)', 'C2'),
(6, 13, 'base de données NoSQL CJ', 'C1'),
(6, 6, 'Classification de données textuelles', 'C2'),
(6, 18, 'Applications en économie et gestion (A. Delachaux)', 'C3'),
(6, 4, 'Portfolio', 'C3'),
(6, 5, 'Dolesup', 'C3'),
(6, 7, 'Classification automatique (renforcements)', 'C2');

-- ============================================================
-- 6. INSERTION DES PREUVES (CUMULATIVES)
-- ============================================================

INSERT INTO PREUVE (id_ac, fichier) VALUES 
('AC11.01', '1043.png'),
('AC11.02', '2032.png'),
('AC11.02', '1013.png'),
('AC11.03', '1023.png'),
('AC11.04', '1011.png'),
('AC11.05', '2013.png'),
('AC21.01', '2033.png'),
('AC21.02', '2013.png'),
('AC21.03', '2012.png');


