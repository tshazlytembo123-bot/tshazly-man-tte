import express from "express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pkg from "pg";

const { Pool, Client } = pkg;

const app = express();
const PORT = 3000;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ==============================
// 1️⃣ Configuration PostgreSQL
// ==============================
const DB_CONFIG = {
  host: "localhost",
  user: "postgres",
  password: "",
  database: "butsd",
  port: 5432
};

const INIT_SQL_FILE = path.join(__dirname, "init_db.sql");

// ==============================
// 2️⃣ Créer la base si nécessaire
// ==============================
async function ensureDatabase() {
  const client = new Client({
    host: DB_CONFIG.host,
    user: DB_CONFIG.user,
    password: DB_CONFIG.password,
    database: "postgres",
    port: DB_CONFIG.port
  });

  await client.connect();

  const result = await client.query(
    "SELECT 1 FROM pg_database WHERE datname = $1",
    [DB_CONFIG.database]
  );

  if (result.rowCount === 0) {
    console.log(`🛠️  Base '${DB_CONFIG.database}' inexistante, création en cours...`);
    await client.query(`CREATE DATABASE ${DB_CONFIG.database}`);
    console.log(`✅ Base '${DB_CONFIG.database}' créée.`);
  } else {
    console.log(`ℹ️  Base '${DB_CONFIG.database}' déjà existante.`);
  }

  await client.end();
}

// ==============================
// 3️⃣ Exécuter le fichier SQL
// ==============================
async function initTables() {
  const sql = fs.readFileSync(INIT_SQL_FILE, "utf-8");
  const pool = new Pool(DB_CONFIG);

  try {
    await pool.query(sql);
    console.log("✅ Tables et données initialisées depuis init_db.sql");
  } finally {
    await pool.end();
  }
}

// ==============================
// 4️⃣ Démarrage du serveur
// ==============================
async function startServer() {
  try {
    await ensureDatabase();
    await initTables();

    const pool = new Pool(DB_CONFIG);

    app.use(express.json());
    app.use(express.static(path.join(__dirname, "public")));
    app.use("/preuves", express.static(path.join(__dirname, "preuves")));

    // Apprentissages critiques
    app.get("/api/apprentissage_critique", async (req, res) => {
      try {
        const { annee, competence } = req.query;
        const conditions = [];
        const parameters = [];

        if (annee) {
          parameters.push(annee.toUpperCase());
          conditions.push(`ac.id_annee = $${parameters.length}`);
        }

        if (competence) {
          parameters.push(String(competence).replace(/^C/i, ""));
          conditions.push(`SUBSTRING(ac.id_ac FROM 3 FOR 1) = $${parameters.length}`);
        }

        const where = conditions.length > 0
          ? `WHERE ${conditions.join(" AND ")}`
          : "";

        const query = `
          SELECT ac.id_ac,
                 ac.intitule,
                 ac.id_annee,
                 ac.niveau,
                 ('C' || SUBSTRING(ac.id_ac FROM 3 FOR 1)) AS id_competence
          FROM APPRENTISSAGE_CRITIQUE ac
          ${where}
          ORDER BY ac.id_ac;
        `;

        const { rows } = await pool.query(query, parameters);
        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des apprentissages critiques" });
      }
    });

    app.get("/api/apprentissage_critique/:id", async (req, res) => {
      try {
        const { rows } = await pool.query(`
          SELECT ac.id_ac,
                 ac.intitule,
                 ac.id_annee,
                 ac.niveau,
                 ('C' || SUBSTRING(ac.id_ac FROM 3 FOR 1)) AS id_competence
          FROM APPRENTISSAGE_CRITIQUE ac
          WHERE ac.id_ac = $1;
        `, [req.params.id.toUpperCase()]);

        if (rows.length === 0) {
          return res.status(404).json({ error: "Apprentissage critique non trouvé" });
        }

        res.json(rows[0]);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération de l'apprentissage critique" });
      }
    });

    // Total des heures par compétence
    app.get("/api/heures", async (req, res) => {
      try {
        const { rows } = await pool.query(`
          SELECT c.id_competence,
                 c.intitule,
                 COALESCE(SUM(a.heure), 0)::integer AS total_heures
          FROM COMPETENCE c
          LEFT JOIN ACTIVITE_PEDAGOGIQUE a
            ON a.id_competence = c.id_competence
          GROUP BY c.id_competence, c.intitule
          ORDER BY c.id_competence;
        `);
        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des heures" });
      }
    });

    // Total des heures par compétence et par semestre
    app.get("/api/heures/semestre", async (req, res) => {
      try {
        const { rows } = await pool.query(`
          SELECT a.semestre,
                 c.id_competence,
                 c.intitule,
                 SUM(a.heure)::integer AS total_heures
          FROM ACTIVITE_PEDAGOGIQUE a
          JOIN COMPETENCE c
            ON c.id_competence = a.id_competence
          GROUP BY a.semestre, c.id_competence, c.intitule
          ORDER BY a.semestre, c.id_competence;
        `);
        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des heures par semestre" });
      }
    });

    // Liste des compétences
    app.get("/api/competences", async (req, res) => {
      try {
        const { rows } = await pool.query(`
          SELECT id_competence, intitule, description, preuve
          FROM COMPETENCE
          ORDER BY id_competence;
        `);
        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des compétences" });
      }
    });

    // Une compétence précise
    app.get("/api/competence/:id", async (req, res) => {
      try {
        const id = req.params.id.toUpperCase();
        const { rows } = await pool.query(`
          SELECT id_competence, intitule, description, preuve
          FROM COMPETENCE
          WHERE id_competence = $1;
        `, [id]);

        if (rows.length === 0) {
          return res.status(404).json({ error: "Compétence non trouvée" });
        }

        res.json(rows[0]);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération de la compétence" });
      }
    });

    // Activités pédagogiques
    app.get("/api/activites", async (req, res) => {
      try {
        const { competence, semestre } = req.query;
        const conditions = [];
        const parameters = [];

        if (competence) {
          parameters.push(competence.toUpperCase());
          conditions.push(`a.id_competence = $${parameters.length}`);
        }

        if (semestre) {
          parameters.push(Number(semestre));
          conditions.push(`a.semestre = $${parameters.length}`);
        }

        const where = conditions.length > 0
          ? `WHERE ${conditions.join(" AND ")}`
          : "";

        const { rows } = await pool.query(`
          SELECT a.num,
                 a.semestre,
                 a.heure,
                 a.skill,
                 a.id_competence,
                 c.intitule AS competence
          FROM ACTIVITE_PEDAGOGIQUE a
          JOIN COMPETENCE c ON c.id_competence = a.id_competence
          ${where}
          ORDER BY a.semestre, a.num;
        `, parameters);

        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des activités" });
      }
    });

    // Liste des années
    app.get("/api/annees", async (req, res) => {
      try {
        const { rows } = await pool.query(`
          SELECT id_annee, intitule
          FROM ANNEE
          ORDER BY id_annee;
        `);
        res.json(rows);
      } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Erreur lors de la récupération des années" });
      }
    });

    app.use((req, res) => {
      res.status(404).json({ error: "Route non trouvée" });
    });

    app.listen(PORT, () => {
      console.log(`🌐 Serveur en ligne sur http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ Erreur lors de la préparation de la base :", err);
    process.exitCode = 1;
  }
}

startServer();
