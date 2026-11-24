-- Suppression des tables si existantes (et cascade pour les dépendances)
DROP TABLE IF EXISTS ACTIVITE_PEDAGOGIQUE CASCADE;
DROP TABLE IF EXISTS APPRENTISSAGE_CRITIQUE CASCADE;
DROP TABLE IF EXISTS COMPETENCE CASCADE;
DROP TABLE IF EXISTS ANNEE CASCADE;

-- ============================================================
-- TABLE DES COMPÉTENCES DU BUT SCIENCES DES DONNÉES
-- ============================================================
CREATE TABLE IF NOT EXISTS COMPETENCE (
    id_competence CHAR(2) PRIMARY KEY,  -- C1 à C4
    intitule TEXT NOT NULL,
    description TEXT NOT NULL,
    preuve TEXT
);

INSERT INTO COMPETENCE (id_competence, intitule, description, preuve) VALUES
('C1', 'Traiter des données à des fins décisionnelles', $$
En intervenant à toutes les étapes du cycle de vie de la donnée (insertion, modification, extraction, suppression)
En utilisant le modèle de données adapté aux besoins
En s’inscrivant dans une démarche de documentation des réalisations adaptée au public visé
En traduisant correctement les demandes métier en programmes, avec le respect du cahier des charges s'il existe
En écrivant un programme correctement structuré et documenté, respectant les bonnes pratiques
En identifiant les librairies et langages dédiés
$$, 'test1.jpg'),
('C2', 'Analyser statistiquement les données', $$
En tenant compte du contexte de l’étude (économique, socio-démographique, commerciale, clinique...)
En mettant en évidence les grandes tendances et les informations principales
En identifiant et en mettant en œuvre les techniques adaptées aux attentes du client ou de l’instance décisionnaire
En identifiant et en mettant en œuvre les techniques adaptées aux données complexes (données massives, données mal structurées, flux de données…)
En tenant compte du contexte inférentiel (variabilité de l’échantillon)
$$, 'test4.png'),
('C3', 'Valoriser une production dans un contexte professionnel', $$
En s’adaptant au niveau d’expertise, à la culture et au statut du destinataire
En s’exprimant correctement, aussi bien en français qu’en anglais, à l'oral comme à l'écrit
En veillant aux aspects éthiques, déontologiques et réglementaires d’utilisation et de diffusion des données
En interprétant et contextualisant les résultats (citations, vérification des sources, esprit critique)
En utilisant la forme de restitution adaptée
En tenant compte des réalités économiques et managériales des entreprises
$$, 'test3.jpg'),
('C4', 'Développer un outil décisionnel', $$
En mettant en œuvre une structuration des données adaptée à leurs caractéristiques (type, volume...)
En assurant la qualité des données et minimisant les biais liés à l’incertitude et l’imprécision dans les sources
En étant sensible aux aspects éthiques, déontologiques et juridiques d’utilisation et de diffusion des données
En réalisant des solutions de visualisation spécifiques aux données métier
En intervenant à différents niveaux de la chaîne décisionnelle
En utilisant des méthodes de développement logiciel
$$, 'test4.png')
ON CONFLICT DO NOTHING;


-- ============================================================
-- TABLE DES ANNÉES
-- ============================================================
CREATE TABLE IF NOT EXISTS ANNEE (
    id_annee CHAR(4) PRIMARY KEY,  -- ex: BUT1, BUT2, BUT3
    intitule TEXT NOT NULL
);

INSERT INTO ANNEE (id_annee, intitule) VALUES
('BUT1', 'Traiter des données structurées / Mettre en œuvre une analyse descriptive / Contextualiser et présenter les données'),
('BUT2', 'Automatiser le traitement de données multidimensionnelles / Mettre en œuvre une analyse exploratoire / Restituer et argumenter ses résultats / Développer un composant d’une solution décisionnelle'),
('BUT3', 'Intégrer le traitement de données complexes / Mettre en œuvre l''analyse exploratoire de données complexes / Intégrer et valoriser sa production dans l''écosystème de l''entreprise / Participer au déploiement d''une solution décisionnelle')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TABLE DES ACTIVITÉS PÉDAGOGIQUES
-- ============================================================
CREATE TABLE IF NOT EXISTS ACTIVITE_PEDAGOGIQUE (
    num INT PRIMARY KEY,
    semestre INT NOT NULL,
    heure INT NOT NULL,
    skill TEXT NOT NULL,
    id_competence CHAR(2) NOT NULL,
    FOREIGN KEY (id_competence) REFERENCES COMPETENCE(id_competence)
);

INSERT INTO ACTIVITE_PEDAGOGIQUE (num, semestre, heure, skill, id_competence) VALUES
(1, 1, 30, 'Collecter et préparer des données issues de sources variées', 'C1'),
(2, 1, 45, 'Appliquer des traitements de nettoyage et de transformation', 'C1'),
(3, 1, 40, 'Programmer des scripts pour manipuler les données', 'C3'),
(4, 1, 25, 'Présenter les premiers résultats d’analyse', 'C4'),
(5, 2, 40, 'Concevoir et interroger une base de données relationnelle', 'C1'),
(6, 2, 35, 'Réaliser une visualisation adaptée à un jeu de données', 'C4'),
(7, 2, 40, 'Mettre en œuvre des méthodes statistiques descriptives et inférentielles', 'C2'),
(8, 3, 45, 'Développer un programme d’analyse automatisée', 'C3'),
(9, 3, 30, 'Effectuer une veille technologique et scientifique en science des données', 'C3'),
(10, 3, 35, 'Travailler en équipe sur un projet de traitement de données', 'C3'),
(11, 4, 40, 'Concevoir une chaîne complète d’analyse de données (ETL)', 'C3'),
(12, 4, 30, 'Mettre en œuvre des algorithmes d’apprentissage automatique supervisé', 'C2'),
(13, 4, 25, 'Documenter et versionner le code d’un projet', 'C4'),
(14, 5, 40, 'Déployer une solution d’analyse sur un serveur ou dans le cloud', 'C3'),
(15, 5, 30, 'Mettre en place un traitement distribué sur de grands volumes de données', 'C3'),
(16, 5, 25, 'Créer un tableau de bord décisionnel interactif', 'C4'),
(17, 6, 40, 'Piloter un projet complet de science des données', 'C3'),
(18, 6, 35, 'Évaluer la performance et la robustesse d’un modèle prédictif', 'C2'),
(19, 6, 20, 'Communiquer les résultats à des décideurs non techniques', 'C4'),
(20, 6, 30, 'Garantir la conformité, la qualité et l’éthique dans la gestion des données', 'C2')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TABLE DES APPRENTISSAGES CRITIQUES
-- ============================================================
CREATE TABLE IF NOT EXISTS APPRENTISSAGE_CRITIQUE (
    id_ac VARCHAR(12) PRIMARY KEY,      -- ex: AC11.01, AC24.02VCOD
    intitule TEXT NOT NULL,             -- description complète
    id_annee CHAR(4) NOT NULL,         -- référence au BUT
    niveau INT,                         -- optionnel, 1 à 3
    FOREIGN KEY (id_annee) REFERENCES ANNEE(id_annee)
);

-- BUT1 : Traiter des données structurées
INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC11.01', 'Correctement interpréter et prendre en compte le besoin du commanditaire ou du client', 'BUT1'),
('AC11.02', 'Respecter les formalismes de notation', 'BUT1'),
('AC11.03', 'Connaître la syntaxe des langages et savoir l’utiliser', 'BUT1'),
('AC11.04', 'Mesurer l’importance de maîtriser la structure des données à exploiter', 'BUT1'),
('AC11.05', 'Comprendre les structures algorithmiques de base et leur contexte d’usage', 'BUT1'),
('AC11.06', 'Prendre conscience de l’intérêt de la programmation', 'BUT1'),
('AC12.01', 'Réaliser que les sources de données ont des caractéristiques propres à considérer (variation, précision, mise à jour...)', 'BUT1'),
('AC12.02', 'Comprendre qu’une analyse correcte ne peut émaner que de données propres et préparées', 'BUT1'),
('AC12.03', 'Comprendre l’intérêt des synthèses numériques et graphiques pour décrire une variable statistique', 'BUT1'),
('AC12.04', 'Comprendre l’intérêt des synthèses numériques et graphiques pour mettre en évidence des liaisons entre variables.', 'BUT1'),
('AC12.05', 'Comprendre l''intérêt de l’utilisation d’un modèle probabiliste', 'BUT1'),
('AC12.06', 'Appréhender la notion de fluctuation d''échantillonnage, notamment à l’aide de simulations probabilistes', 'BUT1'),
('AC13.01', 'Prendre connaissance des biais rencontrés dans la mise en place d’une enquête', 'BUT1'),
('AC13.02', 'Identifier l’importance de contextualiser ses données', 'BUT1'),
('AC13.03', 'Mesurer l’importance de mettre en évidence des résultats clés par l’utilisation d’indicateurs pertinents', 'BUT1'),
('AC13.04', 'Lors de la restitution des résultats, mesurer l’importance d’expliciter également la démarche suivie', 'BUT1'),
('AC13.05', 'Comprendre les intérêts de la data visualisation et de l’infographie', 'BUT1'),
('AC13.06', 'Mesurer l’importance d’une expression précise et nuancée dans la communication en français et dans une langue étrangère des résultats', 'BUT1')
ON CONFLICT DO NOTHING;

-- BUT2 : Automatiser le traitement de données multidimensionnelles
INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC21.01', 'Comprendre l''organisation des données de l''entreprise', 'BUT2'),
('AC21.02', 'Réaliser le rôle central et spécifique de l''entrepôt de données dans la chaine décisionnelle', 'BUT2'),
('AC21.03', 'Identifier et résoudre les problèmes d’intégration de sources complémentaires et hétérogènes', 'BUT2'),
('AC21.04', 'Comprendre la nécessité de tester, corriger et documenter un programme', 'BUT2'),
('AC21.05', 'Apprécier l’intérêt de briques logicielles existantes et savoir les utiliser', 'BUT2')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC22.01', 'Prendre conscience de la différence entre modélisation statistique et analyse exploratoire', 'BUT2'),
('AC22.02', 'Saisir la spécificité de l’analyse des données temporelles', 'BUT2'),
('AC22.03', 'Comprendre l’intérêt des analyses multivariées pour synthétiser et résumer l’information portée par plusieurs variables', 'BUT2'),
('AC22.04', 'Appréhender l’idée de confronter une hypothèse avec la réalité pour prendre une décision', 'BUT2'),
('AC22.05', 'Apprécier les limites de validité et les conditions d’application d’une analyse', 'BUT2')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC23.01', 'Saisir l’intérêt de mobiliser de manière proactive des ressources métiers liées à l''environnement (y compris économique, international…)', 'BUT2'),
('AC23.02', 'Savoir défendre ses choix d’analyses', 'BUT2'),
('AC23.03', 'Saisir la nécessité de choisir des indicateurs pertinents pour communiquer sur les résultats', 'BUT2'),
('AC23.04', 'Prendre conscience de la rigueur requise dans ses productions et dans la communication à leur propos', 'BUT2'),
('AC23.05', 'Comprendre les enjeux des relations en milieu professionnel adaptées à l’interlocuteur et à sa culture', 'BUT2')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC24.01VCOD', 'Comprendre le rôle fondamental de l’analyse des besoins et de l’existant dans un projet décisionnel (architecture, visualisation...)', 'BUT2'),
('AC24.02VCOD', 'Percevoir les enjeux de l’automatisation et de l''interopérabilité d’un ensemble de tâches', 'BUT2'),
('AC24.03VCOD', 'Prendre conscience des différences entre outils (logiciels, langages) pour choisir le plus adapté', 'BUT2'),
('AC24.04VCOD', 'Comprendre le cycle de vie d’un projet informatique', 'BUT2')
ON CONFLICT DO NOTHING;

-- BUT3 : Intégrer le traitement de données complexes
INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC31.01', 'Identifier les solutions technologiques permettant la collecte et la diffusion de données', 'BUT3'),
('AC31.02', 'Comprendre les spécificités des données complexes et de leur exploitation', 'BUT3'),
('AC31.03', 'Savoir mener une veille technologique', 'BUT3')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC32.01', 'Prendre conscience des différences entre des outils statistiques pour choisir le plus adapté', 'BUT3'),
('AC32.02', 'Saisir l’importance de la mise en œuvre de méthodes adaptées à des domaines et des données spécifiques (Marketing, Biostatistique, Statistique spatiale, Gestion …)', 'BUT3'),
('AC32.03', 'Prendre conscience des limites des méthodes classiques pour l’analyse des données complexes (données massives, données mal structurées…)', 'BUT3'),
('AC32.04', 'Comprendre les mécanismes de bases de l’intelligence artificielle (apprentissage statistique supervisé, échantillons d''apprentissage et échantillons de test…)', 'BUT3')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC33.01', 'Savoir transformer la donnée pour la mettre en conformité avec des normes (anonymisation, normalisation)', 'BUT3'),
('AC33.02', 'Mesurer l''impact d''un respect de la législation en terme de droit des données.', 'BUT3'),
('AC33.03', 'Identifier les clés d''une bonne communication (procédures et techniques utilisées)', 'BUT3'),
('AC33.04', 'Mesurer l’importance de comprendre et de répondre à l''ensemble des problématiques posées', 'BUT3'),
('AC33.05', 'Être force de proposition', 'BUT3'),
('AC33.06', 'Prendre conscience de la nécessité d’intégrer la vision de l’interlocuteur (transversalité, international, multiculture, niveau d’expertise…)', 'BUT3')
ON CONFLICT DO NOTHING;

INSERT INTO APPRENTISSAGE_CRITIQUE (id_ac, intitule, id_annee) VALUES
('AC34.01VCOD', 'Prendre conscience de la nécessité d’utiliser des moyens spécifiques pour exploiter les Big Data ou les flux de données', 'BUT3'),
('AC34.02VCOD', 'Défendre ses choix de solution par un argumentaire éclairé', 'BUT3'),
('AC34.03VCOD', 'Réaliser l’intérêt d’appliquer les méthodes de développement dans la réalisation d’un projet informatique', 'BUT3'),
('AC34.04VCOD', 'Apprécier l’intérêt de l’utilisation d’un gestionnaire de versions de code', 'BUT3')
ON CONFLICT DO NOTHING;

    
