#!/usr/bin/env bash
# Regenerates data/publications.json from PubMed (E-utilities, no key needed).
# Edit QUERY / EXCLUDE below, then run: scripts/update_publications.sh
set -euo pipefail
cd "$(dirname "$0")/.."
QUERY='((Ravi VM[Author] OR Joseph K[Author]) AND Freiburg[Affiliation]) OR 38653236[PMID]'
# PMIDs from homonymous authors or unrelated work. One per line, keep sorted.
EXCLUDE='26821584 27412669 41308689 42790282'
E=https://eutils.ncbi.nlm.nih.gov/entrez/eutils
ids=$(curl -sG "$E/esearch.fcgi" --data-urlencode db=pubmed --data-urlencode "term=$QUERY" \
      --data-urlencode retmax=500 --data-urlencode retmode=json \
      | python3 -I -c 'import json,sys;print(",".join(json.load(sys.stdin)["esearchresult"]["idlist"]))')
curl -sG "$E/esummary.fcgi" --data-urlencode db=pubmed --data-urlencode "id=$ids" --data-urlencode retmode=json \
  | EXCLUDE="$EXCLUDE" python3 -I -c '
import json,sys,os
ex=set(os.environ["EXCLUDE"].split()); d=json.load(sys.stdin)["result"]; out=[]
for k in d["uids"]:
    if k in ex: continue
    r=d[k]; ids={a["idtype"]:a["value"] for a in r.get("articleids",[])}
    out.append({"pmid":k,"year":int(r["pubdate"][:4]),"date":r.get("sortpubdate","")[:10],
      "title":r["title"].rstrip("."),"journal":r["fulljournalname"],
      "authors":[a["name"] for a in r["authors"]],"doi":ids.get("doi",""),"pmc":ids.get("pmc","")})
out.sort(key=lambda p:p["date"],reverse=True)
json.dump(out,open("data/publications.json","w"),indent=1,ensure_ascii=False)
print(len(out),"publications written to data/publications.json")'
