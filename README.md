# 3D-Brain Models Lab website

Static site for https://3dbmandne-lab.github.io (PI Dr. Vidhya M. Ravi) — plain HTML, CSS and vanilla JS, no build step.

- `index.html`, `research.html`, `publications.html`, `people.html` — pages
- `data/publications.json` — regenerate with `scripts/update_publications.sh` (PubMed E-utilities; edit the query, the exclusion list and the CODE map of PMID→repository in the script)
- `assets/` — stylesheet, script, favicon

Edit the HTML directly for text changes. Commit and push to `main`; GitHub Pages serves the root.
