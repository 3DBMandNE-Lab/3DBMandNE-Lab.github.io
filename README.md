# 3DBM&NE Lab website

Static site for https://3dbmandne-lab.github.io — plain HTML, CSS and vanilla JS, no build step.

- `index.html`, `research.html`, `publications.html`, `software.html`, `people.html` — pages
- `data/publications.json` — regenerate with `scripts/update_publications.sh` (PubMed E-utilities; edit the query and exclusion list in the script)
- `data/repos.json` — regenerate with `scripts/update_repos.sh` (needs `gh`; lists non-fork public repos with a description)
- `assets/` — stylesheet, script, favicon

Edit the HTML directly for text changes. Commit and push to `main`; GitHub Pages serves the root.
