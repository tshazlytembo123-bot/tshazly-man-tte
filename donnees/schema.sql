-- ============================================================
-- schema.sql : structure de la base PostgreSQL « butsd »
-- Tables, contraintes et vues utilisées par le serveur (serveur/server.js).
-- Ce fichier est rejoué en entier par `npm run init` : il supprime puis recrée tout.
-- Les données sont dans donnees.sql (exécuté juste après).
-- ============================================================

-- 1. Nettoyage (ordre sans importance grâce à CASCADE)
DROP VIEW  IF EXISTS v_kpi_accueil, v_volume_horaire, v_moyenne_semestre, v_notes_tranche, v_notes_detail CASCADE;
DROP TABLE IF EXISTS PREUVE, NOTE, MODULE, ACTIVITE_PEDAGOGIQUE, APPRENTISSAGE_CRITIQUE,
                     PROJET_TECHNOLOGIE, PROJET, TECHNOLOGIE, DOCUMENT, SEMESTRE, ANNEE, COMPETENCE CASCADE;

-- 2. Parcours BUT Science des Données ------------------------

CREATE TABLE COMPETENCE (
    id_competence      CHAR(2) PRIMARY KEY CHECK (id_competence IN ('C1','C2','C3','C4')),
    nom_court          TEXT NOT NULL,          -- Traiter, Analyser, Valoriser, Développer
    intitule           TEXT NOT NULL,          -- intitulé officiel
    description        TEXT NOT NULL,          -- composantes essentielles (texte officiel)
    description_courte TEXT                    -- phrase affichée dans la carte
);

CREATE TABLE ANNEE (
    id_annee CHAR(4) PRIMARY KEY CHECK (id_annee IN ('BUT1','BUT2','BUT3')),
    intitule TEXT NOT NULL
);

CREATE TABLE SEMESTRE (
    num                             INT PRIMARY KEY CHECK (num BETWEEN 1 AND 6),
    id_annee                        CHAR(4) NOT NULL REFERENCES ANNEE(id_annee),
    annee_universitaire             TEXT,
    heures_enseignement_nationales  INT,
    heures_projet_tutore_nationales INT,
    stage_semaines_min              INT,
    stage_semaines_max              INT,
    statut_validation               TEXT NOT NULL
        CHECK (statut_validation IN ('valide','en_cours','a_venir','a_saisir','non_valide')),
    moyenne_officielle              NUMERIC(4,2) CHECK (moyenne_officielle IS NULL OR moyenne_officielle BETWEEN 0 AND 20),
    commentaire                     TEXT
);

CREATE TABLE APPRENTISSAGE_CRITIQUE (
    id_ac           VARCHAR(12) PRIMARY KEY,      -- ex. AC11.01, AC24.02VCOD
    id_annee        CHAR(4) NOT NULL REFERENCES ANNEE(id_annee),
    id_competence   CHAR(2) NOT NULL REFERENCES COMPETENCE(id_competence),
    niveau          INT NOT NULL CHECK (niveau BETWEEN 1 AND 3),   -- niveau de développement de la compétence (C4 : 1 à 2)
    intitule_niveau TEXT NOT NULL,                -- ex. « Traiter des données structurées »
    libelle_court   TEXT NOT NULL,                -- formulation courte (panneau de détail)
    intitule        TEXT NOT NULL                 -- formulation officielle complète
);

CREATE TABLE ACTIVITE_PEDAGOGIQUE (               -- volume horaire réel (emploi du temps)
    num           SERIAL PRIMARY KEY,
    semestre      INT NOT NULL REFERENCES SEMESTRE(num),
    heure         INT NOT NULL CHECK (heure > 0),
    skill         TEXT NOT NULL,
    id_competence CHAR(2) NOT NULL REFERENCES COMPETENCE(id_competence)
);

CREATE TABLE PREUVE (                             -- images de preuve, rangées dans preuves/
    id_preuve SERIAL PRIMARY KEY,
    id_ac     VARCHAR(12) NOT NULL REFERENCES APPRENTISSAGE_CRITIQUE(id_ac) ON DELETE CASCADE,
    fichier   TEXT NOT NULL
);

CREATE TABLE MODULE (
    code          TEXT PRIMARY KEY,               -- ex. R1.04, SAE2.01
    semestre      INT NOT NULL REFERENCES SEMESTRE(num),
    type          TEXT NOT NULL CHECK (type IN ('ressource','sae','stage','portfolio')),
    intitule      TEXT NOT NULL,
    id_competence CHAR(2) REFERENCES COMPETENCE(id_competence),   -- NULL = transversal (PPP) ou à compléter
    statut        TEXT NOT NULL DEFAULT 'a_valider' CHECK (statut IN ('ok','a_valider','a_completer'))
);

CREATE TABLE NOTE (
    id                 TEXT PRIMARY KEY,          -- N001, N002…
    code_module        TEXT NOT NULL REFERENCES MODULE(code),
    note               NUMERIC(4,2) NOT NULL CHECK (note BETWEEN 0 AND 20),
    coefficient        NUMERIC(5,2) NOT NULL DEFAULT 1 CHECK (coefficient > 0),
    libelle_evaluation TEXT,
    statut             TEXT NOT NULL DEFAULT 'ok' CHECK (statut IN ('ok','a_valider','a_completer'))
);

-- 3. Portfolio -----------------------------------------------

CREATE TABLE TECHNOLOGIE (
    id      TEXT PRIMARY KEY,
    nom     TEXT NOT NULL UNIQUE,
    famille TEXT NOT NULL CHECK (famille IN ('Langages','Données','Visualisation','Outils')),
    niveau  INT CHECK (niveau IS NULL OR niveau BETWEEN 1 AND 5),
    statut  TEXT NOT NULL DEFAULT 'a_valider' CHECK (statut IN ('ok','a_valider','a_completer'))
);

CREATE TABLE PROJET (
    id                TEXT PRIMARY KEY,
    titre             TEXT NOT NULL,
    description       TEXT,
    categorie         TEXT NOT NULL CHECK (categorie IN ('Académique','Personnel','Santé & secteur public')),
    objectif          TEXT,
    donnees_utilisees TEXT,
    difficultes       TEXT,
    lien_code         TEXT,
    visuel            TEXT,
    statut            TEXT NOT NULL DEFAULT 'a_valider' CHECK (statut IN ('ok','a_valider','a_completer'))
);

CREATE TABLE PROJET_TECHNOLOGIE (
    id_projet      TEXT NOT NULL REFERENCES PROJET(id) ON DELETE CASCADE,
    id_technologie TEXT NOT NULL REFERENCES TECHNOLOGIE(id) ON DELETE CASCADE,
    PRIMARY KEY (id_projet, id_technologie)
);

CREATE TABLE DOCUMENT (
    id      TEXT PRIMARY KEY,
    titre   TEXT NOT NULL,
    type    TEXT NOT NULL CHECK (type IN ('CV','Attestations','Rapports')),
    date    DATE,
    fichier TEXT NOT NULL,                        -- chemin relatif servi par le site (maquette/…, documents/…)
    statut  TEXT NOT NULL DEFAULT 'a_valider' CHECK (statut IN ('ok','a_valider','a_completer'))
);

-- 4. Vues utilisées par les contrôleurs ----------------------

-- Une ligne par note, avec semestre et compétence (section Notes)
CREATE VIEW v_notes_detail AS
SELECT n.id, n.note, n.coefficient, n.libelle_evaluation,
       m.code AS module_code, m.intitule AS module, m.type AS module_type,
       m.id_competence, s.num AS semestre_num, 'S' || s.num AS semestre, s.id_annee
FROM NOTE n
JOIN MODULE m   ON m.code = n.code_module
JOIN SEMESTRE s ON s.num  = m.semestre
WHERE n.statut <> 'a_completer';

-- Tranche de chaque note (histogramme : <8, 8-10, 10-12, 12-14, >14)
CREATE VIEW v_notes_tranche AS
SELECT *,
  CASE WHEN note < 8  THEN '<8'
       WHEN note < 10 THEN '8-10'
       WHEN note < 12 THEN '10-12'
       WHEN note < 14 THEN '12-14'
       ELSE '>14' END AS tranche
FROM v_notes_detail;

-- Moyenne pondérée par semestre (courbe de progression)
CREATE VIEW v_moyenne_semestre AS
SELECT semestre, semestre_num,
       ROUND(SUM(note * coefficient) / SUM(coefficient), 2) AS moyenne,
       COUNT(*) AS nb_evaluations
FROM v_notes_detail
GROUP BY semestre, semestre_num;

-- Volume horaire par compétence et par année de BUT (graphique en barres)
CREATE VIEW v_volume_horaire AS
SELECT s.id_annee, s.num AS semestre_num, a.id_competence, SUM(a.heure)::INT AS heures
FROM ACTIVITE_PEDAGOGIQUE a
JOIN SEMESTRE s ON s.num = a.semestre
GROUP BY s.id_annee, s.num, a.id_competence;

-- Les quatre compteurs de la page d'accueil
CREATE VIEW v_kpi_accueil AS
SELECT
  (SELECT COALESCE(SUM(heure), 0) FROM ACTIVITE_PEDAGOGIQUE)::INT                    AS heures_formation,
  (SELECT ROUND(SUM(note * coefficient) / SUM(coefficient), 2) FROM v_notes_detail)  AS moyenne_generale,
  (SELECT COUNT(*) FROM PROJET WHERE statut <> 'a_completer')::INT                   AS projets_realises,
  (SELECT COUNT(*) FROM SEMESTRE WHERE statut_validation = 'valide')::INT            AS semestres_valides;
