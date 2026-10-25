# 3D-Brain Models Lab website

Static site for https://3dbmandne-lab.github.io (PI Dr. Vidhya M. Ravi) — plain HTML, CSS and vanilla JS, no build step.

- `index.html`, `research.html`, `publications.html`, `software.html`, `people.html` — pages
- `data/publications.json` — regenerate with `scripts/update_publications.sh` (PubMed E-utilities; edit the query and exclusion list in the script)
- `data/repos.json` — regenerate with `scripts/update_repos.sh` (needs `gh`; publishes only the repositories named in its INCLUDE list)
- `assets/` — stylesheet, script, favicon

Edit the HTML directly for text changes. Commit and push to `main`; GitHub Pages serves the root.
