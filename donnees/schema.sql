

CREATE TABLE competences (
  code              TEXT PRIMARY KEY,               -- C1 à C4
  nom_court         TEXT NOT NULL,
  intitule          TEXT NOT NULL,
  description_courte TEXT
);

CREATE TABLE apprentissages_critiques (
  code              TEXT PRIMARY KEY,               -- ex. AC11.01
  competence_code   TEXT NOT NULL REFERENCES competences(code),
  niveau            INTEGER NOT NULL CHECK (niveau BETWEEN 1 AND 3),
  intitule_niveau   TEXT NOT NULL,
  libelle_court     TEXT NOT NULL
);

CREATE TABLE semestres (
  id                TEXT PRIMARY KEY,               -- S1 à S6
  annee_but         INTEGER NOT NULL CHECK (annee_but BETWEEN 1 AND 3),
  annee_universitaire TEXT,
  heures_enseignement_nationales INTEGER,
  heures_projet_tutore_nationales INTEGER,
  stage_semaines_min INTEGER,
  stage_semaines_max INTEGER,
  statut_validation TEXT NOT NULL
      CHECK (statut_validation IN ('valide','en_cours','a_venir','a_saisir','non_valide')),
  moyenne_officielle REAL CHECK (moyenne_officielle IS NULL OR moyenne_officielle BETWEEN 0 AND 20),
  commentaire       TEXT
);

CREATE TABLE modules (
  code              TEXT PRIMARY KEY,               -- ex. R1.04, SAE2.01
  semestre_id       TEXT NOT NULL REFERENCES semestres(id),
  type              TEXT NOT NULL CHECK (type IN ('ressource','sae','stage','portfolio')),
  intitule          TEXT NOT NULL,
  competence_code   TEXT REFERENCES competences(code),  -- NULL = transversal (PPP) ou à compléter
  heures            INTEGER CHECK (heures IS NULL OR heures >= 0)
);

CREATE TABLE notes (
  id                TEXT PRIMARY KEY,
  module_code       TEXT NOT NULL REFERENCES modules(code),
  note              REAL NOT NULL CHECK (note BETWEEN 0 AND 20),
  coefficient       REAL NOT NULL DEFAULT 1 CHECK (coefficient > 0),
  libelle_evaluation TEXT
);

CREATE TABLE technologies (
  id                TEXT PRIMARY KEY,
  nom               TEXT NOT NULL UNIQUE,
  famille           TEXT NOT NULL CHECK (famille IN ('Langages','Données','Visualisation','Outils')),
  niveau            INTEGER CHECK (niveau IS NULL OR niveau BETWEEN 1 AND 5)
);

CREATE TABLE projets (
  id                TEXT PRIMARY KEY,
  titre             TEXT NOT NULL,
  description       TEXT,
  categorie         TEXT NOT NULL CHECK (categorie IN ('Académique','Personnel','Santé & secteur public')),
  objectif          TEXT,
  donnees_utilisees TEXT,
  difficultes       TEXT,
  lien_code         TEXT,
  visuel            TEXT
);

CREATE TABLE projets_professionnel (
  projet_id         TEXT NOT NULL REFERENCES projets(id),
  professionnel_id    TEXT NOT NULL REFERENCES professionnel(id),
  PRIMARY KEY (projet_id, technologie_id)
);

CREATE TABLE documents (
  id                TEXT PRIMARY KEY,
  titre             TEXT NOT NULL,
  type              TEXT NOT NULL CHECK (type IN ('CV','Attestations','Rapports')),
  date              TEXT,
  fichier           TEXT NOT NULL
);

-- ---------- Vues utilisées par les contrôleurs ----------

-- Une ligne par note, avec semestre, année et compétence (base de la section Notes)
CREATE VIEW v_notes_detail AS
SELECT n.id, n.note, n.coefficient, n.libelle_evaluation,
       m.code AS module_code, m.intitule AS module, m.type AS module_type,
       m.competence_code,
       s.id AS semestre, s.annee_but
FROM notes n
JOIN modules m ON m.code = n.module_code
JOIN semestres s ON s.id = m.semestre_id;

-- Tranche de chaque note (histogramme de la maquette : <8, 8-10, 10-12, 12-14, >14)
CREATE VIEW v_notes_tranche AS
SELECT *,
  CASE WHEN note < 8  THEN '<8'
       WHEN note < 10 THEN '8-10'
       WHEN note < 12 THEN '10-12'
       WHEN note < 14 THEN '12-14'
       ELSE '>14' END AS tranche
FROM v_notes_detail;

-- Moyenne pondérée calculée par semestre (courbe de progression)
CREATE VIEW v_moyenne_semestre AS
SELECT semestre, annee_but,
       ROUND(SUM(note * coefficient) / SUM(coefficient), 2) AS moyenne,
       COUNT(*) AS nb_evaluations
FROM v_notes_detail
GROUP BY semestre, annee_but;

-- Volume horaire par compétence et par année (graphique en barres BUT 1/2/3)
CREATE VIEW v_volume_horaire_competence AS
SELECT s.annee_but, COALESCE(m.competence_code, 'TRANSVERSAL') AS competence_code,
       SUM(m.heures) AS heures
FROM modules m
JOIN semestres s ON s.id = m.semestre_id
WHERE m.heures IS NOT NULL
GROUP BY s.annee_but, COALESCE(m.competence_code, 'TRANSVERSAL');

-- Les quatre compteurs de la page d'accueil
CREATE VIEW v_kpi_accueil AS
SELECT
  (SELECT COALESCE(SUM(heures), 0) FROM modules
     WHERE semestre_id IN (SELECT id FROM semestres WHERE statut_validation = 'valide')) AS heures_formation,
  (SELECT ROUND(SUM(note * coefficient) / SUM(coefficient), 2) FROM notes) AS moyenne_generale,
  (SELECT COUNT(*) FROM projets)                                           AS projets_realises,
  (SELECT COUNT(*) FROM semestres WHERE statut_validation = 'valide')      AS semestres_valides;
