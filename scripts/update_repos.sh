#!/usr/bin/env bash
# Regenerates data/repos.json from the public repositories of the GitHub org. Requires gh.
# KIND: tool = reusable software; resource = datasets/teaching; project = code accompanying a study (default).
# PAPER: PMID of the published paper for a project repo. STATUS: free text when there is no PMID yet.
set -euo pipefail
cd "$(dirname "$0")/.."
KIND='atman=tool cloupe-to-10x=tool MicroFace=tool SIH_CSF_Proteomics=tool LGG_mIHC=tool
      Neural_ECM=resource SpatialBiologyWorkshop_Freiburg2026=resource'
PAPER='GBM_IronMetabolism=42844997 MicroFace=42389604'
STATUS='TNF_Synpo=Kleidonas et al., manuscript under review
LGG_Hypoxia=Das et al. 2026
Npas4_Cortical_Injury=Töykkälä et al. 2026'
gh repo list 3DBMandNE-Lab --limit 100 --visibility public \
  --json name,description,url,homepageUrl,primaryLanguage,stargazerCount,isFork,repositoryTopics,pushedAt \
  | KIND="$KIND" PAPER="$PAPER" STATUS="$STATUS" python3 -I -c '
import json,sys,os
kv=lambda s,sep:dict(x.split("=",1) for x in s.split(sep) if "=" in x)
kind=kv(os.environ["KIND"].replace("\n"," ")," "); paper=kv(os.environ["PAPER"]," "); status=kv(os.environ["STATUS"],"\n")
rs=[r for r in json.load(sys.stdin) if not r["isFork"] and r["description"] and not r["name"].endswith(".github.io")]
rs.sort(key=lambda r:r["pushedAt"],reverse=True)
out=[{"name":r["name"],"description":r["description"],"url":r["url"],"homepage":r["homepageUrl"],
      "language":(r["primaryLanguage"] or {}).get("name",""),"stars":r["stargazerCount"],
      "topics":[t["name"] for t in r["repositoryTopics"] or []],"pushed":r["pushedAt"][:10],
      "kind":kind.get(r["name"],"project"),"paper":paper.get(r["name"],""),"status":status.get(r["name"],"")} for r in rs]
json.dump(out,open("data/repos.json","w"),indent=1,ensure_ascii=False); print(len(out),"repos written to data/repos.json")'
