#!/usr/bin/env bash
# Regenerates data/abstracts.json (conference abstracts, conference papers, preprints) from the public ORCID record.
set -euo pipefail
cd "$(dirname "$0")/.."
ORCID=0000-0003-0062-2099
# DOIs to skip: figshare data deposits are filtered by title; anything else goes here.
SKIP='10.1038/srep33776'
curl -s -H "Accept: application/json" "https://pub.orcid.org/v3.0/$ORCID/record" \
  | SKIP="$SKIP" python3 -I -c '
import json,sys,os,re,html
skip=set(os.environ["SKIP"].split())
KEEP={"gbm","jak","stat","idh","idh1","idh2","d-2hg","r-2","2hg","scrna-seq","sptcr-seq","t","ampa","braf","human2human","perampanel","glioblastoma","interleukin","il-10","rna","dna","tcr","mri","cns"}
FIX={"scrna-seq":"scRNA-seq","sptcr-seq":"SPTCR-seq","human2human":"Human2Human","perampanel":"Perampanel","glioblastoma":"glioblastoma","interleukin":"Interleukin","d-2hg":"D-2HG","r-2":"R-2","il-10":"IL-10"}
def clean(t):
    t=re.sub(r"\s+"," ",html.unescape(re.sub("<[^>]+>"," ",t))).strip()
    t=re.sub(r"^(?:[A-Z]{2,5}-\d+\.|P\d+\.\d+(?:\.[A-Z])?|OS\d+\.\d+[A-Z]?)\s*","",t)   # leading SNO/EANO abstract codes
    letters=[c for c in t if c.isalpha()]
    if letters and sum(c.isupper() for c in letters)/len(letters)>0.8:                                                           # ALL CAPS -> sentence case with protected tokens
        words=t.lower().split(); out=[]
        for i,w in enumerate(words):
            core=w.strip("(),.;:")
            if core in FIX: w=w.replace(core,FIX[core])
            elif core in KEEP: w=w.replace(core,core.upper())
            if i==0: w=w[0].upper()+w[1:]
            out.append(w)
        t=" ".join(out)
    return t
a=json.load(sys.stdin)["activities-summary"]; out=[]
for g in a["works"]["group"]:
    s=g["work-summary"][0]; typ=s["type"]
    if typ not in ("conference-abstract","conference-paper","preprint","other"): continue
    ids={e["external-id-type"]:e["external-id-value"] for e in g.get("external-ids",{}).get("external-id",[])}
    doi=ids.get("doi","")
    raw=s["title"]["title"]["value"]
    if raw.startswith(("Data from","Supplementary")) or doi in skip: continue
    y=(s.get("publication-date") or {}).get("year") or {}
    venue=((s.get("journal-title") or {}).get("value") or "").replace("Biorxiv","bioRxiv").replace("BioRxiv","bioRxiv") or ("Research Square" if "rs.3.rs" in doi else "bioRxiv" if "10.1101" in doi else "")
    kind="preprint" if typ in ("preprint","other") else "abstract"
    out.append({"year":int(y.get("value",0)),"kind":kind,"title":clean(raw),"venue":venue,"doi":doi})
out.sort(key=lambda w:(-w["year"],w["kind"],w["title"]))
json.dump(out,open("data/abstracts.json","w"),indent=1,ensure_ascii=False); print(len(out),"abstracts/preprints written to data/abstracts.json")'
