#!/usr/bin/env python3
"""Valide les fichiers CSV de donnees/ puis construit la base SQLite data/portfolio.db.

Usage :
    python scripts/charger_donnees.py            # valide et construit la base
    python scripts/charger_donnees.py --verifier # valide seulement (aucune base créée)

Règle des statuts (colonne « statut » des CSV) :
    ok           ligne complète, chargée et publiée sur le site
    a_valider    ligne chargée, mais à relire (niveau, source, texte provisoire...)
    a_completer  ligne NON chargée tant qu'elle n'est pas remplie
"""
import csv
import sqlite3
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
DONNEES = RACINE / "donnees"
BASE = RACINE / "data" / "portfolio.db"
SCHEMA = DONNEES / "schema.sql"

STATUTS = {"ok", "a_valider", "a_completer"}
erreurs, avertissements = [], []


def lire(nom):
    """Lit un CSV (séparateur « ; », UTF-8) et remplace les cases vides par None."""
    chemin = DONNEES / nom
    with open(chemin, newline="", encoding="utf-8-sig") as f:
        lignes = []
        for i, brut in enumerate(csv.DictReader(f, delimiter=";"), start=2):
            ligne = {k.strip(): (v.strip() if v and v.strip() else None) for k, v in brut.items()}
            ligne["_ligne"] = i
            lignes.append(ligne)
    return lignes


def err(nom, ligne, message):
    erreurs.append(f"{nom} (ligne {ligne['_ligne']}) : {message}")


def nombre(valeur, nom, ligne, champ, mini=None, maxi=None, entier=False):
    """Convertit en nombre (accepte la virgule décimale de Excel). Renvoie None si vide."""
    if valeur is None:
        return None
    try:
        x = float(valeur.replace(",", "."))
    except ValueError:
        err(nom, ligne, f"« {champ} » n'est pas un nombre : {valeur!r}")
        return None
    if entier:
        x = int(x)
    if (mini is not None and x < mini) or (maxi is not None and x > maxi):
        err(nom, ligne, f"« {champ} » hors limites ({mini} à {maxi}) : {x}")
        return None
    return x


def statut_ok(nom, ligne):
    s = ligne.get("statut")
    if s not in STATUTS:
        err(nom, ligne, f"statut invalide : {s!r} (attendu : ok, a_valider, a_completer)")
        return None
    return s


def charger():
    t = {}
    # --- tables de référence -------------------------------------------------
    t["competences"] = lire("competences.csv")
    codes_comp = {l["code"] for l in t["competences"]}
    t["apprentissages_critiques"] = lire("apprentissages_critiques.csv")
    for l in t["apprentissages_critiques"]:
        if l["competence_code"] not in codes_comp:
            err("apprentissages_critiques.csv", l, f"compétence inconnue : {l['competence_code']}")

    t["semestres"] = lire("semestres.csv")
    ids_sem = {l["id"] for l in t["semestres"]}
    valeurs_validation = {"valide", "en_cours", "a_venir", "a_saisir", "non_valide"}
    for l in t["semestres"]:
        if l["statut_validation"] not in valeurs_validation:
            err("semestres.csv", l, f"statut_validation invalide : {l['statut_validation']!r}")

    # --- modules -------------------------------------------------------------
    t["modules"] = lire("modules.csv")
    codes_mod, vus = set(), set()
    for l in t["modules"]:
        if l["code"] in vus:
            err("modules.csv", l, f"code en double : {l['code']}")
        vus.add(l["code"])
        if l["semestre_id"] not in ids_sem:
            err("modules.csv", l, f"semestre inconnu : {l['semestre_id']}")
        if l["type"] not in {"ressource", "sae", "stage", "portfolio"}:
            err("modules.csv", l, f"type invalide : {l['type']!r}")
        if l["competence_code"] and l["competence_code"] not in codes_comp:
            err("modules.csv", l, f"compétence inconnue : {l['competence_code']}")
        l["heures"] = nombre(l["heures"], "modules.csv", l, "heures", mini=0, entier=True)
        codes_mod.add(l["code"])

    # contrôle : les heures saisies ne dépassent pas le volume national du semestre
    for s in t["semestres"]:
        total = sum(m["heures"] or 0 for m in t["modules"] if m["semestre_id"] == s["id"])
        nat = nombre(s["heures_enseignement_nationales"], "semestres.csv", s, "heures_enseignement_nationales", entier=True)
        if nat is not None and total > nat:
            err("semestres.csv", s, f"{s['id']} : {total} h saisies dans modules.csv > {nat} h nationales")

    # --- notes ---------------------------------------------------------------
    t["notes"] = []
    ids = set()
    for l in lire("notes.csv"):
        s = statut_ok("notes.csv", l)
        if l["id"] in ids:
            err("notes.csv", l, f"id en double : {l['id']}")
        ids.add(l["id"])
        if l["module_code"] not in codes_mod:
            err("notes.csv", l, f"module inconnu : {l['module_code']}")
        l["note"] = nombre(l["note"], "notes.csv", l, "note", 0, 20)
        l["coefficient"] = nombre(l["coefficient"], "notes.csv", l, "coefficient", mini=0.0001)
        if s in ("ok", "a_valider"):
            if l["note"] is None or l["coefficient"] is None:
                err("notes.csv", l, "statut 'ok'/'a_valider' mais note ou coefficient manquant")
        t["notes"].append(l)

    # --- technologies --------------------------------------------------------
    t["technologies"] = lire("technologies.csv")
    ids_tech = set()
    for l in t["technologies"]:
        statut_ok("technologies.csv", l)
        ids_tech.add(l["id"])
        if l["famille"] not in {"Langages", "Données", "Visualisation", "Outils"}:
            err("technologies.csv", l, f"famille invalide : {l['famille']!r}")
        l["niveau"] = nombre(l["niveau"], "technologies.csv", l, "niveau", 1, 5, entier=True)

    # --- projets -------------------------------------------------------------
    t["projets"] = lire("projets.csv")
    ids_proj = set()
    for l in t["projets"]:
        statut_ok("projets.csv", l)
        ids_proj.add(l["id"])
        if l["categorie"] not in {"Académique", "Personnel", "Santé & secteur public"}:
            err("projets.csv", l, f"catégorie invalide : {l['categorie']!r}")
    t["projets_technologies"] = lire("projets_technologies.csv")
    for l in t["projets_technologies"]:
        if l["projet_id"] not in ids_proj:
            err("projets_technologies.csv", l, f"projet inconnu : {l['projet_id']}")
        if l["technologie_id"] not in ids_tech:
            err("projets_technologies.csv", l, f"technologie inconnue : {l['technologie_id']}")

    # --- documents -----------------------------------------------------------
    t["documents"] = lire("documents.csv")
    for l in t["documents"]:
        s = statut_ok("documents.csv", l)
        if l["type"] not in {"CV", "Attestations", "Rapports"}:
            err("documents.csv", l, f"type invalide : {l['type']!r}")
        if s == "ok" and not (RACINE / l["fichier"]).exists():
            avertissements.append(f"documents.csv (ligne {l['_ligne']}) : le fichier {l['fichier']} est introuvable dans le dépôt")
    return t


def a_charger(table, lignes):
    """Les lignes « a_completer » ne sont pas chargées (notes, technologies, projets, documents)."""
    if table in {"notes", "technologies", "projets", "documents"}:
        return [l for l in lignes if l.get("statut") in ("ok", "a_valider")]
    return lignes


COLONNES = {
    "competences": ["code", "nom_court", "intitule", "description_courte"],
    "apprentissages_critiques": ["code", "competence_code", "niveau", "intitule_niveau", "libelle_court"],
    "semestres": ["id", "annee_but", "annee_universitaire", "heures_enseignement_nationales",
                  "heures_projet_tutore_nationales", "stage_semaines_min", "stage_semaines_max",
                  "statut_validation", "moyenne_officielle", "commentaire"],
    "modules": ["code", "semestre_id", "type", "intitule", "competence_code", "heures"],
    "notes": ["id", "module_code", "note", "coefficient", "libelle_evaluation"],
    "technologies": ["id", "nom", "famille", "niveau"],
    "projets": ["id", "titre", "description", "categorie", "objectif", "donnees_utilisees",
                "difficultes", "lien_code", "visuel"],
    "projets_technologies": ["projet_id", "technologie_id"],
    "documents": ["id", "titre", "type", "date", "fichier"],
}
ORDRE = ["competences", "apprentissages_critiques", "semestres", "modules", "notes",
         "technologies", "projets", "projets_technologies", "documents"]


def construire(t):
    BASE.parent.mkdir(exist_ok=True)
    if BASE.exists():
        BASE.unlink()
    con = sqlite3.connect(BASE)
    con.executescript(SCHEMA.read_text(encoding="utf-8"))
    for table in ORDRE:
        cols = COLONNES[table]
        lignes = a_charger(table, t[table])
        con.executemany(
            f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join('?' for _ in cols)})",
            [[l.get(c) for c in cols] for l in lignes],
        )
    con.commit()
    return con


def rapport(t, con):
    print("\nRésumé du chargement")
    print("-" * 60)
    for table in ORDRE:
        lignes = t[table]
        if lignes and "statut" in lignes[0]:
            nb = {s: sum(1 for l in lignes if l["statut"] == s) for s in STATUTS}
            print(f"{table:26s} {nb['ok']:3d} ok · {nb['a_valider']:3d} à valider · {nb['a_completer']:3d} à compléter")
        else:
            print(f"{table:26s} {len(lignes):3d} lignes")
    if con is not None:
        kpi = con.execute("SELECT * FROM v_kpi_accueil").fetchone()
        print(f"\nCompteurs de l'accueil : heures={kpi[0]} · moyenne={kpi[1]} · projets={kpi[2]} · semestres validés={kpi[3]}")
        # comparaison avec les moyennes officielles saisies
        for sem, off, calc in con.execute(
            "SELECT s.id, s.moyenne_officielle, v.moyenne FROM semestres s "
            "JOIN v_moyenne_semestre v ON v.semestre = s.id WHERE s.moyenne_officielle IS NOT NULL"
        ):
            ecart = abs(off - calc)
            if ecart > 0.5:
                avertissements.append(
                    f"{sem} : moyenne calculée {calc} vs moyenne officielle {off} (écart {ecart:.2f}) : "
                    "vérifie les coefficients de notes.csv")


def main():
    seulement_verifier = "--verifier" in sys.argv
    t = charger()
    con = None if (seulement_verifier or erreurs) else construire(t)
    rapport(t, con)
    for a in avertissements:
        print("Avertissement :", a)
    if erreurs:
        print("\nErreurs à corriger :")
        for e in erreurs:
            print("  -", e)
        sys.exit(1)
    print("\nDonnées valides." + ("" if seulement_verifier else f" Base créée : {BASE.relative_to(RACINE)}"))


if __name__ == "__main__":
    main()
