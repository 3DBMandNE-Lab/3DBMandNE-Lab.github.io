#!/usr/bin/env bash
# Regenerates data/repos.json from the public repositories of the GitHub org. Requires gh.
# INCLUDE: only repositories belonging to the 3D-Brain Models Lab's studies are published on the site.
# KIND: tool = reusable software; resource = datasets/teaching; project = code accompanying a study (default).
# PAPER: PMID of the published paper for a project repo. STATUS: free text when there is no PMID yet.
set -euo pipefail
cd "$(dirname "$0")/.."
INCLUDE='GBM_IronMetabolism LGG_Hypoxia LGG_mIHC GBM_CarPBMC Meningeoma_PharmaAtlas Neural_ECM SpatialBiologyWorkshop_Freiburg2026'
KIND='Neural_ECM=resource SpatialBiologyWorkshop_Freiburg2026=resource'
PAPER='GBM_IronMetabolism=42844997'
STATUS='LGG_Hypoxia=Das et al. 2026'
gh repo list 3DBMandNE-Lab --limit 100 --visibility public \
  --json name,description,url,homepageUrl,primaryLanguage,stargazerCount,isFork,repositoryTopics,pushedAt \
  | INCLUDE="$INCLUDE" KIND="$KIND" PAPER="$PAPER" STATUS="$STATUS" python3 -I -c '
import json,sys,os
kv=lambda s,sep:dict(x.split("=",1) for x in s.split(sep) if "=" in x)
kind=kv(os.environ["KIND"].replace("\n"," ")," "); paper=kv(os.environ["PAPER"]," "); status=kv(os.environ["STATUS"],"\n")
inc=set(os.environ["INCLUDE"].split())
rs=[r for r in json.load(sys.stdin) if r["name"] in inc and r["description"]]
rs.sort(key=lambda r:r["pushedAt"],reverse=True)
out=[{"name":r["name"],"description":r["description"],"url":r["url"],"homepage":r["homepageUrl"],
      "language":(r["primaryLanguage"] or {}).get("name",""),"stars":r["stargazerCount"],
      "topics":[t["name"] for t in r["repositoryTopics"] or []],"pushed":r["pushedAt"][:10],
      "kind":kind.get(r["name"],"project"),"paper":paper.get(r["name"],""),"status":status.get(r["name"],"")} for r in rs]
json.dump(out,open("data/repos.json","w"),indent=1,ensure_ascii=False); print(len(out),"repos written to data/repos.json")'
