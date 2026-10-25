#!/usr/bin/env bash
# Regenerates data/repos.json from the public repositories of the GitHub org. Requires gh.
set -euo pipefail
cd "$(dirname "$0")/.."
gh repo list 3DBMandNE-Lab --limit 100 --visibility public \
  --json name,description,url,homepageUrl,primaryLanguage,stargazerCount,isFork,repositoryTopics,pushedAt \
  | python3 -I -c '
import json,sys
rs=[r for r in json.load(sys.stdin) if not r["isFork"] and r["description"]]
rs.sort(key=lambda r:r["pushedAt"],reverse=True)
out=[{"name":r["name"],"description":r["description"],"url":r["url"],"homepage":r["homepageUrl"],
      "language":(r["primaryLanguage"] or {}).get("name",""),"stars":r["stargazerCount"],
      "topics":[t["name"] for t in r["repositoryTopics"] or []],"pushed":r["pushedAt"][:10]} for r in rs]
json.dump(out,open("data/repos.json","w"),indent=1); print(len(out),"repos written to data/repos.json")'
