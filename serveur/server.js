// ============================================================
// server.js : contrôleur Node.js / Express + base PostgreSQL « butsd »
//
//   npm install          (une seule fois)
//   npm run init         (crée la base si besoin et recharge donnees/schema.sql + donnees/donnees.sql)
//   npm start            (démarre http://localhost:3000)
//
// Au démarrage, la base est créée et remplie automatiquement si elle est vide.
// Ajouter `--reset` (ou RESET_DB=1) force un rechargement complet.
// ============================================================
import express from "express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pkg from "pg";

const { Pool, Client } = pkg;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const RACINE = path.resolve(__dirname, "..");

// ==============================
// 1. Configuration (modifiable par variables d'environnement, voir .env.example)
// ==============================
const PORT = Number(process.env.PORT) || 3000;

const DB_NAME = process.env.DB_NAME || "butsd";
if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(DB_NAME)) {
  throw new Error(`Nom de base invalide : « ${DB_NAME} » (lettres, chiffres et _ uniquement)`);
}

// DATABASE_URL (hébergeur) est prioritaire ; la base existe alors déjà, on ne tente pas de la créer.
const UTILISE_URL = Boolean(process.env.DATABASE_URL);
const DB_CONFIG = UTILISE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.DB_SSL === "1" ? { rejectUnauthorized: false } : undefined
    }
  : {
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER || "postgres",
      password: process.env.DB_PASSWORD ?? "",
      database: DB_NAME,
      port: Number(process.env.DB_PORT) || 5432
    };

const FICHIERS_SQL = [
  path.join(RACINE, "donnees", "schema.sql"),
  path.join(RACINE, "donnees", "donnees.sql")
];

const CONTACT = {
  email: process.env.CONTACT_EMAIL || "tshazlytembo123@gmail.com",
  linkedin: process.env.CONTACT_LINKEDIN || "https://www.linkedin.com/in/tshazly-tte-tembo",
  github: process.env.CONTACT_GITHUB || "https://github.com/tshazlytembo123-bot"
};

// ==============================
// 2. Créer la base si nécessaire
// ==============================
async function ensureDatabase() {
  if (UTILISE_URL) return;

  const client = new Client({ ...DB_CONFIG, database: "postgres" });
  await client.connect();
  try {
    const result = await client.query("SELECT 1 FROM pg_database WHERE datname = $1", [DB_NAME]);
    if (result.rowCount === 0) {
      console.log(`🛠️  Base '${DB_NAME}' inexistante, création en cours...`);
      await client.query(`CREATE DATABASE "${DB_NAME}"`); // nom validé plus haut
      console.log(`✅ Base '${DB_NAME}' créée.`);
    } else {
      console.log(`ℹ️  Base '${DB_NAME}' déjà existante.`);
    }
  } finally {
    await client.end();
  }
}

// ==============================
// 3. Créer les tables et charger les données
// ==============================
async function schemaPresent(pool) {
  const { rows } = await pool.query("SELECT to_regclass('public.apprentissage_critique') AS t");
  return rows[0].t !== null;
}

async function initTables(pool) {
  const sql = FICHIERS_SQL.map((f) => fs.readFileSync(f, "utf-8")).join("\n");
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query(sql);
    await client.query("COMMIT");
    console.log("✅ Tables, vues et données initialisées (schema.sql + donnees.sql)");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

// ==============================
// 4. Outils pour les routes
// ==============================
class ErreurHttp extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

// Capte les erreurs des routes async et les envoie au gestionnaire d'erreurs
const route = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

const estVide = (v) => v === undefined || v === null || v === "" || /^(tous|tout|toutes)$/i.test(String(v));

// « BUT1 », « but2 », « 3 » → « BUT1 » / « BUT2 » / « BUT3 » ; vide ou « toutes » → null
function parseAnnee(v) {
  if (estVide(v)) return null;
  const m = String(v).trim().match(/^(?:BUT)?\s*([123])$/i);
  if (!m) throw new ErreurHttp(400, "Paramètre annee invalide (attendu : 1, 2, 3, BUT1, BUT2 ou BUT3)");
  return `BUT${m[1]}`;
}

// « S3 », « s3 », « 3 » → 3 ; vide ou « Tous » → null
function parseSemestre(v) {
  if (estVide(v)) return null;
  const m = String(v).trim().match(/^S?\s*([1-6])$/i);
  if (!m) throw new ErreurHttp(400, "Paramètre semestre invalide (attendu : S1 à S6 ou Tous)");
  return Number(m[1]);
}

// « C2 », « c2 » → « C2 »
function parseCompetence(v) {
  if (estVide(v)) return null;
  const m = String(v).trim().match(/^C?\s*([1-4])$/i);
  if (!m) throw new ErreurHttp(400, "Paramètre competence invalide (attendu : C1 à C4)");
  return `C${m[1]}`;
}

const CATEGORIES = ["Académique", "Personnel", "Santé & secteur public"];
const FAMILLES = ["Langages", "Données", "Visualisation", "Outils"];
const TYPES_DOC = ["CV", "Attestations", "Rapports"];

function parseListe(v, valeurs, nom) {
  if (estVide(v)) return null;
  const trouve = valeurs.find((x) => x.toLowerCase() === String(v).trim().toLowerCase());
  if (!trouve) throw new ErreurHttp(400, `Paramètre ${nom} invalide (attendu : ${valeurs.join(", ")} ou Tous)`);
  return trouve;
}

// ==============================
// 5. Démarrage du serveur
// ==============================
async function startServer() {
  const args = process.argv.slice(2);
  const initSeulement = args.includes("--init");
  const reset = initSeulement || args.includes("--reset") || process.env.RESET_DB === "1";

  let pool;
  try {
    await ensureDatabase();
    pool = new Pool(DB_CONFIG);

    if (reset || !(await schemaPresent(pool))) {
      await initTables(pool);
    } else {
      console.log("ℹ️  Schéma déjà présent (utiliser `npm run init` pour le recharger).");
    }
    if (initSeulement) {
      await pool.end();
      return;
    }
  } catch (err) {
    console.error("❌ Impossible de préparer la base PostgreSQL :", err.message);
    console.error("   Vérifier que PostgreSQL est lancé et que DB_HOST / DB_USER / DB_PASSWORD (ou DATABASE_URL) sont corrects.");
    if (pool) await pool.end().catch(() => {});
    process.exitCode = 1;
    return;
  }

  const app = express();
  app.disable("x-powered-by");
  app.use(express.json());

  // Seuls ces dossiers sont publics. Le dossier prive/ (CV complet, lettre…) n'est jamais servi.
  app.use(express.static(path.join(RACINE, "public")));
  app.use("/preuves", express.static(path.join(RACINE, "preuves")));
  app.use("/maquette", express.static(path.join(RACINE, "maquette")));
  app.use("/documents", express.static(path.join(RACINE, "documents")));

  const api = express.Router();

  // ---------- Santé ----------
  api.get("/sante", route(async (req, res) => {
    await pool.query("SELECT 1");
    res.json({ ok: true });
  }));

  // ---------- Années ----------
  api.get("/annees", route(async (req, res) => {
    const { rows } = await pool.query("SELECT id_annee, intitule FROM ANNEE ORDER BY id_annee");
    res.json(rows);
  }));

  // ---------- Compétences ----------
  api.get("/competences", route(async (req, res) => {
    const { rows } = await pool.query(`
      SELECT id_competence, nom_court, intitule, description, description_courte
      FROM COMPETENCE ORDER BY id_competence`);
    res.json(rows);
  }));

  // Une compétence + ses apprentissages critiques + ses preuves (deux chemins : ancien et celui de l'architecture)
  api.get(["/competence/:id", "/competences/:id"], route(async (req, res) => {
    let id = null;
    try { id = parseCompetence(req.params.id); } catch { /* identifiant mal formé : traité comme introuvable */ }
    if (!id) throw new ErreurHttp(404, "Compétence non trouvée");

    const comp = await pool.query(`
      SELECT id_competence, nom_court, intitule, description, description_courte
      FROM COMPETENCE WHERE id_competence = $1`, [id]);
    if (comp.rowCount === 0) throw new ErreurHttp(404, "Compétence non trouvée");

    const acs = await pool.query(`
      SELECT id_ac, intitule, libelle_court, id_annee, niveau, intitule_niveau
      FROM APPRENTISSAGE_CRITIQUE WHERE id_competence = $1 ORDER BY id_ac`, [id]);
    const preuves = await pool.query(`
      SELECT p.id_ac, p.fichier
      FROM PREUVE p JOIN APPRENTISSAGE_CRITIQUE a ON a.id_ac = p.id_ac
      WHERE a.id_competence = $1 ORDER BY p.id_preuve`, [id]);

    res.json({
      ...comp.rows[0],
      apprentissages: acs.rows,
      preuves: preuves.rows,
      preuve: preuves.rows[0]?.fichier ?? null // première preuve (compatibilité avec l'ancienne page)
    });
  }));

  // ---------- Apprentissages critiques ----------
  api.get("/apprentissage_critique", route(async (req, res) => {
    const annee = parseAnnee(req.query.annee);
    const competence = parseCompetence(req.query.competence);
    const { rows } = await pool.query(`
      SELECT id_ac, intitule, libelle_court, id_annee, niveau, intitule_niveau, id_competence
      FROM APPRENTISSAGE_CRITIQUE
      WHERE ($1::text IS NULL OR id_annee = $1::text)
        AND ($2::text IS NULL OR id_competence = $2::text)
      ORDER BY id_ac`, [annee, competence]);
    res.json(rows);
  }));

  api.get("/apprentissage_critique/:id", route(async (req, res) => {
    const { rows } = await pool.query(`
      SELECT id_ac, intitule, libelle_court, id_annee, niveau, intitule_niveau, id_competence
      FROM APPRENTISSAGE_CRITIQUE WHERE id_ac = $1`, [req.params.id.toUpperCase()]);
    if (rows.length === 0) throw new ErreurHttp(404, "Apprentissage critique non trouvé");
    res.json(rows[0]);
  }));

  // ---------- Volume horaire ----------
  // Total d'heures par compétence, filtrable par année de BUT (aussi disponible sous /volume-horaire)
  api.get(["/heures", "/volume-horaire"], route(async (req, res) => {
    const annee = parseAnnee(req.query.annee);
    const { rows } = await pool.query(`
      SELECT c.id_competence, c.nom_court, c.intitule,
             COALESCE(SUM(v.heures), 0)::int AS total_heures
      FROM COMPETENCE c
      LEFT JOIN v_volume_horaire v
             ON v.id_competence = c.id_competence
            AND ($1::text IS NULL OR v.id_annee = $1::text)
      GROUP BY c.id_competence, c.nom_court, c.intitule
      ORDER BY c.id_competence`, [annee]);
    res.json(rows);
  }));

  // Total d'heures par compétence et par semestre
  api.get("/heures/semestre", route(async (req, res) => {
    const { rows } = await pool.query(`
      SELECT a.semestre, c.id_competence, c.intitule, SUM(a.heure)::int AS total_heures
      FROM ACTIVITE_PEDAGOGIQUE a
      JOIN COMPETENCE c ON c.id_competence = a.id_competence
      GROUP BY a.semestre, c.id_competence, c.intitule
      ORDER BY a.semestre, c.id_competence`);
    res.json(rows);
  }));

  // Détail des activités
  api.get("/activites", route(async (req, res) => {
    const competence = parseCompetence(req.query.competence);
    const semestre = parseSemestre(req.query.semestre);
    const { rows } = await pool.query(`
      SELECT a.num, a.semestre, a.heure, a.skill, a.id_competence, c.intitule AS competence
      FROM ACTIVITE_PEDAGOGIQUE a
      JOIN COMPETENCE c ON c.id_competence = a.id_competence
      WHERE ($1::text IS NULL OR a.id_competence = $1::text)
        AND ($2::int  IS NULL OR a.semestre = $2::int)
      ORDER BY a.semestre, a.num`, [competence, semestre]);
    res.json(rows);
  }));

  // ---------- Accueil ----------
  api.get("/accueil", route(async (req, res) => {
    const kpi = await pool.query("SELECT * FROM v_kpi_accueil");
    const techs = await pool.query("SELECT id, nom, famille, niveau FROM TECHNOLOGIE WHERE statut <> 'a_completer' ORDER BY id");
    res.json({ compteurs: kpi.rows[0], technologies: techs.rows });
  }));

  // ---------- Technologies ----------
  api.get("/technologies", route(async (req, res) => {
    const famille = parseListe(req.query.famille, FAMILLES, "famille");
    const { rows } = await pool.query(`
      SELECT t.id, t.nom, t.famille, t.niveau,
             COALESCE(ARRAY_AGG(p.titre ORDER BY p.titre) FILTER (WHERE p.id IS NOT NULL), '{}') AS projets
      FROM TECHNOLOGIE t
      LEFT JOIN PROJET_TECHNOLOGIE pt ON pt.id_technologie = t.id
      LEFT JOIN PROJET p ON p.id = pt.id_projet AND p.statut <> 'a_completer'
      WHERE t.statut <> 'a_completer' AND ($1::text IS NULL OR t.famille = $1::text)
      GROUP BY t.id, t.nom, t.famille, t.niveau
      ORDER BY t.id`, [famille]);
    res.json(rows);
  }));

  // ---------- Notes ----------
  // Tout en une réponse : indicateurs, progression, distribution et notes par module (filtres semestre / module)
  api.get("/notes", route(async (req, res) => {
    const semestre = parseSemestre(req.query.semestre);
    const codeModule = estVide(req.query.module) ? null : String(req.query.module).trim();
    const filtre = "($1::int IS NULL OR semestre_num = $1::int) AND ($2::text IS NULL OR module_code = $2::text)";
    const p = [semestre, codeModule];

    const [ind, prog, dist, mods] = await Promise.all([
      pool.query(`
        SELECT ROUND(SUM(note * coefficient) / NULLIF(SUM(coefficient), 0), 2)::float8 AS moyenne,
               MAX(note)::float8 AS meilleure, MIN(note)::float8 AS plus_faible,
               COUNT(*)::int AS evaluations
        FROM v_notes_detail WHERE ${filtre}`, p),
      pool.query(`
        SELECT 'S' || s.num AS semestre, COALESCE(v.moyenne, s.moyenne_officielle)::float8 AS moyenne
        FROM SEMESTRE s LEFT JOIN v_moyenne_semestre v ON v.semestre_num = s.num
        WHERE COALESCE(v.moyenne, s.moyenne_officielle) IS NOT NULL
        ORDER BY s.num`),
      pool.query(`SELECT tranche, COUNT(*)::int AS n FROM v_notes_tranche WHERE ${filtre} GROUP BY tranche`, p),
      pool.query(`
        SELECT module_code AS module, module AS intitule,
               ROUND(SUM(note * coefficient) / SUM(coefficient), 2)::float8 AS note
        FROM v_notes_detail WHERE ${filtre}
        GROUP BY module_code, module ORDER BY module_code`, p)
    ]);

    const tranches = ["<8", "8-10", "10-12", "12-14", ">14"];
    const n = Object.fromEntries(dist.rows.map((r) => [r.tranche, r.n]));
    res.json({
      indicateurs: ind.rows[0],
      progression: prog.rows,
      distribution: tranches.map((t) => ({ tranche: t, n: n[t] ?? 0 })),
      par_module: mods.rows
    });
  }));

  // ---------- Projets ----------
  const SQL_PROJETS = `
    SELECT p.id, p.titre, p.description, p.categorie, p.objectif, p.donnees_utilisees,
           p.difficultes, p.lien_code, p.visuel,
           COALESCE(ARRAY_AGG(t.nom ORDER BY t.nom) FILTER (WHERE t.id IS NOT NULL), '{}') AS technologies
    FROM PROJET p
    LEFT JOIN PROJET_TECHNOLOGIE pt ON pt.id_projet = p.id
    LEFT JOIN TECHNOLOGIE t ON t.id = pt.id_technologie`;

  api.get("/projets", route(async (req, res) => {
    const categorie = parseListe(req.query.categorie, CATEGORIES, "categorie");
    const { rows } = await pool.query(`${SQL_PROJETS}
      WHERE p.statut <> 'a_completer' AND ($1::text IS NULL OR p.categorie = $1::text)
      GROUP BY p.id ORDER BY p.id`, [categorie]);
    res.json(rows);
  }));

  api.get("/projets/:id", route(async (req, res) => {
    const { rows } = await pool.query(`${SQL_PROJETS}
      WHERE p.statut <> 'a_completer' AND p.id = $1 GROUP BY p.id`, [req.params.id.toUpperCase()]);
    if (rows.length === 0) throw new ErreurHttp(404, "Projet non trouvé");
    res.json(rows[0]);
  }));

  // ---------- Documents ----------
  // Le chemin du fichier n'est jamais renvoyé tant que le document est « a_completer »
  api.get("/documents", route(async (req, res) => {
    const type = parseListe(req.query.type, TYPES_DOC, "type");
    const { rows } = await pool.query(`
      SELECT id, titre, type, TO_CHAR(date, 'YYYY-MM-DD') AS date,
             CASE WHEN statut = 'a_completer' THEN NULL ELSE fichier END AS fichier, statut
      FROM DOCUMENT WHERE ($1::text IS NULL OR type = $1::text) ORDER BY id`, [type]);
    res.json(rows);
  }));

  // ---------- Tout le portfolio en une réponse (utilisé par public/index.html) ----------
  api.get("/portfolio", route(async (req, res) => {
    const q = (sql) => pool.query(sql).then((r) => r.rows);
    const [competences, apprentissages, semestres, modules, volumes, notes, technologies, projets,
           projets_technologies, documents, preuves, kpi] = await Promise.all([
      q(`SELECT id_competence AS code, nom_court, intitule, description, description_courte
         FROM COMPETENCE ORDER BY id_competence`),
      q(`SELECT id_ac AS code, id_competence AS competence_code, niveau, intitule_niveau, libelle_court, intitule
         FROM APPRENTISSAGE_CRITIQUE ORDER BY id_ac`),
      q(`SELECT 'S' || num AS id, CAST(SUBSTRING(id_annee FROM 4 FOR 1) AS int) AS annee_but,
                annee_universitaire, heures_enseignement_nationales, heures_projet_tutore_nationales,
                stage_semaines_min, stage_semaines_max, statut_validation,
                moyenne_officielle::float8 AS moyenne_officielle, commentaire
         FROM SEMESTRE ORDER BY num`),
      q(`SELECT code, 'S' || semestre AS semestre_id, type, intitule, id_competence AS competence_code, statut
         FROM MODULE ORDER BY semestre, code`),
      q(`SELECT 'S' || semestre_num AS semestre_id, CAST(SUBSTRING(id_annee FROM 4 FOR 1) AS int) AS annee_but,
                id_competence AS competence_code, heures
         FROM v_volume_horaire ORDER BY semestre_num, id_competence`),
      q(`SELECT id, code_module AS module_code, note::float8 AS note, coefficient::float8 AS coefficient, libelle_evaluation
         FROM NOTE WHERE statut <> 'a_completer' ORDER BY id`),
      q(`SELECT id, nom, famille, niveau, statut FROM TECHNOLOGIE WHERE statut <> 'a_completer' ORDER BY id`),
      q(`SELECT id, titre, description, categorie, objectif, donnees_utilisees, difficultes, lien_code, visuel, statut
         FROM PROJET WHERE statut <> 'a_completer' ORDER BY id`),
      q(`SELECT pt.id_projet AS projet_id, pt.id_technologie AS technologie_id
         FROM PROJET_TECHNOLOGIE pt
         JOIN PROJET p ON p.id = pt.id_projet AND p.statut <> 'a_completer'
         JOIN TECHNOLOGIE t ON t.id = pt.id_technologie AND t.statut <> 'a_completer'
         ORDER BY 1, 2`),
      q(`SELECT id, titre, type, TO_CHAR(date, 'YYYY-MM-DD') AS date,
                CASE WHEN statut = 'a_completer' THEN NULL ELSE fichier END AS fichier, statut
         FROM DOCUMENT ORDER BY id`),
      q(`SELECT a.id_competence AS competence_code, p.id_ac, p.fichier
         FROM PREUVE p JOIN APPRENTISSAGE_CRITIQUE a ON a.id_ac = p.id_ac ORDER BY p.id_preuve`),
      q("SELECT * FROM v_kpi_accueil")
    ]);
    res.json({
      competences, apprentissages, semestres, modules, volumes, notes, technologies, projets,
      projets_technologies, documents, preuves, kpi: kpi[0], contact: CONTACT
    });
  }));

  // Route /api inconnue
  api.use((req, res) => res.status(404).json({ error: "Route non trouvée" }));

  app.use("/api", api);

  // Page inconnue
  app.use((req, res) => res.status(404).type("text/plain").send("Page non trouvée"));

  // Gestionnaire d'erreurs : 4xx explicites, 500 pour le reste
  app.use((err, req, res, next) => {
    if (res.headersSent) return next(err);
    const status = err instanceof ErreurHttp ? err.status : 500;
    if (status === 500) console.error(err);
    res.status(status).json({ error: status === 500 ? "Erreur serveur" : err.message });
  });

  const serveur = app.listen(PORT, () => {
    console.log(`🌐 Serveur en ligne sur http://localhost:${PORT}`);
  });
  serveur.on("error", (err) => {
    console.error(err.code === "EADDRINUSE" ? `❌ Le port ${PORT} est déjà utilisé (changer PORT).` : err);
    process.exitCode = 1;
  });

  const arret = () => serveur.close(() => pool.end().then(() => process.exit(0)));
  process.on("SIGINT", arret);
  process.on("SIGTERM", arret);
}

startServer();
