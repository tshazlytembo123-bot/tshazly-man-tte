#!/usr/bin/env python3
"""Construit html_site_web/index.html : insère les données des CSV (donnees/) dans template.html.

Usage :  python scripts/generer_site.py
Les lignes « a_completer » ne sont pas publiées (sauf documents, affichés « À venir »).
Aucune donnée n'est écrite en dur dans la page : modifier un CSV puis relancer ce script.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import charger_donnees as cd  # noqa: E402

CONTACT = {
    "email": "tshazlytembo123@gmail.com",
    "linkedin": "https://www.linkedin.com/in/tshazly-tte-tembo",
    "github": "https://github.com/tshazlytembo123-bot",
}
SITE = cd.RACINE / "html_site_web"


def propre(lignes, garder_a_completer=False):
    sortie = []
    for l in lignes:
        if not garder_a_completer and l.get("statut") == "a_completer":
            continue
        sortie.append({k: v for k, v in l.items() if k != "_ligne"})
    return sortie


def main():
    t = cd.charger()
    if cd.erreurs:
        print("Erreurs dans les CSV, site non généré :")
        for e in cd.erreurs:
            print("  -", e)
        sys.exit(1)
    donnees = {
        "competences": propre(t["competences"]),
        "apprentissages": propre(t["apprentissages_critiques"]),
        "semestres": propre(t["semestres"]),
        "modules": propre(t["modules"]),
        "notes": propre(t["notes"]),
        "technologies": propre(t["technologies"]),
        "projets": propre(t["projets"]),
        "projets_technologies": propre(t["projets_technologies"]),
        "documents": propre(t["documents"], garder_a_completer=True),
        "contact": CONTACT,
    }
    js = json.dumps(donnees, ensure_ascii=False).replace("</", "<\\/")
    page = (SITE / "template.html").read_text(encoding="utf-8").replace("/*DATA*/null", js)
    (SITE / "index.html").write_text(page, encoding="utf-8")
    print(f"Site généré : {SITE / 'index.html'} ({len(page) // 1024} Ko)")


if __name__ == "__main__":
    main()
