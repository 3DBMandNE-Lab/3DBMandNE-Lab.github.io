(function(){
  const LAB = ["Ravi VM","Ravi V","Madapusi Ravi V"]; // bolded in author lists
  const $ = (s,el=document)=>el.querySelector(s);
  const esc = s=>String(s).replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));

  // mobile nav
  const tog=$(".nav-toggle"), nav=$("#nav");
  if(tog) tog.addEventListener("click",()=>{const o=nav.classList.toggle("open");tog.setAttribute("aria-expanded",o);});

  function authors(list){
    const max=12;
    const html=a=>LAB.includes(a)?`<span class="lab">${esc(a)}</span>`:esc(a);
    if(list.length<=max) return list.map(html).join(", ");
    return list.slice(0,max-2).map(html).join(", ")+", … , "+list.slice(-2).map(html).join(", ");
  }
  function pubHTML(p){
    const href=p.doi?`https://doi.org/${p.doi}`:`https://pubmed.ncbi.nlm.nih.gov/${p.pmid}/`;
    return `<article class="pub">
      <a class="t" href="${href}" target="_blank" rel="noopener">${esc(p.title)}</a>
      <div class="a">${authors(p.authors)}</div>
      <div class="j"><em>${esc(p.journal)}</em> · ${p.year}</div>
      <div class="links"><a href="https://pubmed.ncbi.nlm.nih.gov/${p.pmid}/" target="_blank" rel="noopener">PubMed</a>${p.doi?`<a href="https://doi.org/${p.doi}" target="_blank" rel="noopener">DOI</a>`:""}${p.pmc?`<a href="https://www.ncbi.nlm.nih.gov/pmc/articles/${p.pmc}/" target="_blank" rel="noopener">Full text</a>`:""}${p.code?`<a href="${esc(p.code)}" target="_blank" rel="noopener">Code</a>`:""}</div>
    </article>`;
  }
  const load=f=>fetch(f).then(r=>{if(!r.ok)throw new Error(f+" "+r.status);return r.json();});

  // publications page
  const pubs=$("#pubs");
  if(pubs) load("data/publications.json").then(data=>{
    const q=$("#pub-q"), y=$("#pub-year"), c=$("#pub-count");
    [...new Set(data.map(p=>p.year))].sort((a,b)=>b-a).forEach(v=>{const o=document.createElement("option");o.value=v;o.textContent=v;y.appendChild(o);});
    function render(){
      const s=q.value.trim().toLowerCase(), yr=y.value;
      const hit=data.filter(p=>(!yr||String(p.year)===yr)&&(!s||[p.title,p.journal,...p.authors].join(" ").toLowerCase().includes(s)));
      let out="",last=null;
      for(const p of hit){ if(p.year!==last){out+=`<div class="year-h">${p.year}</div>`;last=p.year;} out+=pubHTML(p); }
      pubs.innerHTML=out||`<p class="muted">No publications match.</p>`;
      c.textContent=`${hit.length} of ${data.length}`;
    }
    q.addEventListener("input",render); y.addEventListener("change",render); render();
  }).catch(e=>{pubs.innerHTML=`<p class="muted">Could not load publications (${esc(e.message)}).</p>`;});

  // home: recent pubs
  const rp=$("#recent-pubs");
  if(rp) load("data/publications.json").then(d=>{rp.innerHTML=d.slice(0,+rp.dataset.limit||5).map(pubHTML).join("");}).catch(()=>{rp.innerHTML="";});

  // publications page: conference abstracts and preprints from ORCID
  const abs=$("#abstracts");
  if(abs) load("data/abstracts.json").then(d=>{
    let out="",last=null;
    for(const w of d){
      if(w.year!==last){out+=`<div class="year-h">${w.year}</div>`;last=w.year;}
      const href=w.doi?`https://doi.org/${w.doi}`:"";
      out+=`<article class="pub compact"><a class="t" href="${href}" target="_blank" rel="noopener">${esc(w.title)}</a><div class="j"><em>${esc(w.venue)}</em> · ${w.kind==="preprint"?"preprint":"conference abstract"}</div></article>`;
    }
    abs.innerHTML=out; const c=$("#abs-count"); if(c) c.textContent=`${d.length}`;
  }).catch(e=>{abs.innerHTML=`<p class="muted">Could not load abstracts (${esc(e.message)}).</p>`;});
})();
