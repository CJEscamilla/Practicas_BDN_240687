import { $, escapeHTML as e, number, loadModel, setupTheme, fillMetrics, fail } from './common.js';

const NS='http://www.w3.org/2000/svg', svg=$('#diagram');
function elem(name,attrs={},text='') { const el=document.createElementNS(NS,name); for(const [k,v] of Object.entries(attrs)) el.setAttribute(k,String(v)); if(text)el.textContent=text; return el; }
function link(a,b){return [a,b].sort().join('\u0000')}
try {
  const model=await loadModel(); fillMetrics(model);
  const relations=model.tables.flatMap(t=>t.foreignKeys.map(f=>({...f,source:t.name})));
  const state={selected:null,focus:false,routeMode:false,route:[],layout:'classic',zoom:1,panX:0,panY:0,width:1,height:1};
  const domain=$('#domain'), query=$('#query'), detail=$('#diagram-detail');
  domain.innerHTML += model.domainNames.map(d=>`<option value="${e(d)}">${e(d)}</option>`).join('');
  const adjacency=new Map(model.tables.map(t=>[t.name,new Set()]));
  for(const r of relations){adjacency.get(r.source)?.add(r.target);adjacency.get(r.target)?.add(r.source)}
  function shortest(start,end){let queue=[[start]],seen=new Set([start]);while(queue.length){const path=queue.shift(),last=path[path.length-1];if(last===end)return path;for(const n of adjacency.get(last)||[])if(!seen.has(n)){seen.add(n);queue.push([...path,n]);}}return []}
  function viewBox(){svg.setAttribute('viewBox',`${state.panX} ${state.panY} ${state.width/state.zoom} ${state.height/state.zoom}`)}
  function reset(){state.zoom=1;state.panX=0;state.panY=0;viewBox()}
  function zoom(factor){const old=state.zoom;state.zoom=Math.max(.35,Math.min(8,state.zoom*factor));state.panX+=(state.width/old-state.width/state.zoom)/2;state.panY+=(state.height/old-state.height/state.zoom)/2;viewBox()}
  function select(name){
    if(state.routeMode){if(state.route.length>=2)state.route=[];state.route.push(name);state.selected=name;
      if(state.route.length===2){const path=shortest(...state.route);detail.textContent=path.length?`Ruta: ${path.join(' → ')}. La ruta usa conexiones declaradas, sin considerar su dirección.`:'No existe una ruta de claves foráneas entre las dos entidades.';}else detail.textContent=`Origen: ${name}. Selecciona una segunda entidad.`;
    }else{state.selected=state.selected===name?null:name;const t=model.tables.find(t=>t.name===state.selected);if(t){const out=relations.filter(r=>r.source===t.name).length,inc=relations.filter(r=>r.target===t.name).length;detail.innerHTML=`<strong>${e(t.name)}</strong> · ${number(t.rows)} filas en el respaldo · ${out} relaciones salientes · ${inc} entrantes. <a href="./index.html#tabla-${encodeURIComponent(t.name)}">Abrir expediente</a>`;}else detail.textContent='Selecciona una entidad para ver su volumen y sus relaciones.';}
    render(false);
  }
  function render(resetView=true){
    const search=query.value.trim().toLocaleLowerCase('es');
    let visible=model.tables.filter(t=>(!domain.value||t.domain===domain.value)&&(!search||JSON.stringify(t).toLocaleLowerCase('es').includes(search)||relations.some(r=>(r.source===t.name||r.target===t.name)&&JSON.stringify(r).toLocaleLowerCase('es').includes(search))));
    if(state.focus&&state.selected){const allowed=new Set([state.selected,...(adjacency.get(state.selected)||[])]);visible=visible.filter(t=>allowed.has(t.name))}
    const themes=document.documentElement.dataset.theme==='light'?{bg:'#ffffff',box:'#f6f8f8',head:'#e4eded',text:'#172329',muted:'#4a6068',line:'#a6b7bd',edge:'#647f87',active:'#a81d1b',fk:'#006d59',pk:'#795200',uq:'#a81d1b'}:{bg:'#151b23',box:'#19232c',head:'#26333d',text:'#edf2f5',muted:'#aab8c4',line:'#425463',edge:'#6c8990',active:'#ff6258',fk:'#99e0cc',pk:'#f2c172',uq:'#ff817b'};
    const domainColors=document.documentElement.dataset.theme==='light'?{Compra:'#b66a30',Auditoría:'#6c7284',Posventa:'#a34346',Pagos:'#6659a8',Identidad:'#276d9a',Catálogo:'#167862',Otros:'#62717a'}:{Compra:'#d7a166',Auditoría:'#a9b2c3',Posventa:'#ed9090',Pagos:'#b7a6f5',Identidad:'#8dbde2',Catálogo:'#8edbbf',Otros:'#a8b6c0'};
    const w=310, gap=68, rowHeight=17, positions=new Map(), domains=model.domainNames.filter(d=>visible.some(t=>t.domain===d));
    let extentX=0,extentY=0;
    if(state.layout==='classic'){
      domains.forEach((d,col)=>{let y=50;const x=30+col*(w+gap);for(const t of visible.filter(x=>x.domain===d)){const h=50+t.columns.length*rowHeight;positions.set(t.name,{x,y,w,h,t});y+=h+32;}extentX=Math.max(extentX,x+w+30);extentY=Math.max(extentY,y+20)});
    }else{
      let columnY=[50,50,50,50];visible.forEach((t,i)=>{const col=i%4,x=30+col*(w+gap),y=columnY[col],h=50+t.columns.length*rowHeight;positions.set(t.name,{x,y,w,h,t});columnY[col]+=h+32;extentX=Math.max(extentX,x+w+30);extentY=Math.max(extentY,columnY[col]+20)});
    }
    state.width=Math.max(extentX+100,640);state.height=Math.max(extentY,420);svg.replaceChildren();
    const title=elem('title',{},'Tablas y relaciones de db_test');svg.append(title);
    const defs=elem('defs');
    for(const [id,color] of [['arrow',themes.edge],['arrow-active',themes.active]]){const marker=elem('marker',{id,viewBox:'0 0 10 10',refX:9,refY:5,markerWidth:7,markerHeight:7,orient:'auto-start-reverse'});marker.append(elem('path',{d:'M 0 0 L 10 5 L 0 10 z',fill:color}));defs.append(marker)}
    svg.append(defs);
    svg.append(elem('rect',{x:0,y:0,width:state.width,height:state.height,fill:themes.bg}));
    if(state.layout==='classic')domains.forEach((d,i)=>svg.append(elem('text',{x:30+i*(w+gap),y:30,fill:domainColors[d]||themes.muted,'font-size':14,'font-family':'system-ui','font-weight':700},d.toUpperCase())));
    const path=state.route.length===2?shortest(...state.route):[],pathEdges=new Set(path.slice(1).map((x,i)=>link(path[i],x)));
    let drawn=0;
    for(const r of relations){const a=positions.get(r.source),b=positions.get(r.target);if(!a||!b)continue;drawn++;
      const y1=a.y+Math.min(a.h-12,44+Math.max(0,a.t.columns.findIndex(c=>r.columns.includes(c.name)))*rowHeight), y2=b.y+Math.min(b.h-12,44+Math.max(0,b.t.columns.findIndex(c=>r.references.includes(c.name)))*rowHeight);
      let x1,x2,d;if(a===b){x1=a.x+a.w;x2=x1;d=`M ${x1} ${y1} C ${x1+52} ${y1-40}, ${x2+52} ${y2+40}, ${x2} ${y2}`;}else if(a.x===b.x){x1=a.x+a.w;x2=b.x+b.w;d=`M ${x1} ${y1} C ${x1+70} ${y1}, ${x2+70} ${y2}, ${x2} ${y2}`;}else{x1=a.x+(a.x<b.x?a.w:0);x2=b.x+(a.x<b.x?0:b.w);const bend=Math.max(40,Math.abs(x2-x1)*.4);d=`M ${x1} ${y1} C ${x1+(x1<x2?bend:-bend)} ${y1}, ${x2+(x1<x2?-bend:bend)} ${y2}, ${x2} ${y2}`;}
      const chosen=pathEdges.has(link(r.source,r.target))||(!path.length&&state.selected&&(r.source===state.selected||r.target===state.selected));
      const edge=elem('path',{d,fill:'none',stroke:chosen?themes.active:themes.edge,'stroke-width':chosen?3:1.2,opacity:(state.selected&&!chosen)?'.24':'.8','marker-end':chosen?'url(#arrow-active)':'url(#arrow)'});edge.append(elem('title',{},`${r.name}: ${r.source} (${r.columns.join(', ')}) → ${r.target} (${r.references.join(', ')})`));svg.append(edge);
      if(chosen){const suffix=r.targetUnique?(r.optional?'0..1':'1'):'?';svg.append(elem('text',{x:x2+(x1<x2?-30:7),y:y2-4,fill:themes.active,'font-size':11,'font-family':'system-ui','font-weight':700},suffix));svg.append(elem('text',{x:x1+(x1<x2?7:-35),y:y1-4,fill:themes.active,'font-size':11,'font-family':'system-ui','font-weight':700},r.unique?'0..1':'0..N'));}
    }
    for(const {x,y,w,h,t} of positions.values()){
      const related=!state.selected||t.name===state.selected||adjacency.get(state.selected)?.has(t.name),g=elem('g',{role:'button',tabindex:'0','data-entity':t.name,'aria-label':`${t.name}, ${t.columns.length} campos, ${t.rows} filas`,opacity:related?'1':'.38'});
      g.append(elem('rect',{x,y,width:w,height:h,rx:7,fill:themes.box,stroke:t.name===state.selected?themes.active:(domainColors[t.domain]||themes.line),'stroke-width':t.name===state.selected?2.5:1}));
      g.append(elem('rect',{x:x+1,y:y+1,width:w-2,height:31,rx:6,fill:themes.head}));
      g.append(elem('text',{x:x+10,y:y+21,fill:themes.text,'font-size':12,'font-weight':700,'font-family':'ui-monospace,Consolas,monospace'},t.name));
      g.append(elem('text',{x:x+w-10,y:y+21,fill:themes.muted,'font-size':10,'text-anchor':'end','font-family':'system-ui'},number(t.rows)));
      t.columns.forEach((c,i)=>{const yy=y+49+i*rowHeight,keys=[c.indexes.some(k=>k.kind==='primary')?'PK':'',c.foreignKeys.length?'FK':'',c.indexes.some(k=>k.kind==='unique')?'UQ':''].filter(Boolean).join('/');
        g.append(elem('text',{x:x+10,y:yy,fill:themes.text,'font-size':10.5,'font-family':'ui-monospace,Consolas,monospace'},c.name.length>27?c.name.slice(0,26)+'…':c.name));
        g.append(elem('text',{x:x+w-10,y:yy,fill:keys.includes('FK')?themes.fk:keys.includes('PK')?themes.pk:keys?themes.uq:themes.muted,'font-size':9,'text-anchor':'end','font-family':'ui-monospace,Consolas,monospace'},`${keys} ${c.type.length>18?c.type.slice(0,17)+'…':c.type}`));
      });
      g.addEventListener('click',()=>select(t.name));g.addEventListener('keydown',ev=>{if(ev.key==='Enter'||ev.key===' '){ev.preventDefault();select(t.name);[...svg.querySelectorAll('g[data-entity]')].find(node=>node.getAttribute('data-entity')===t.name)?.focus()}});svg.append(g);
    }
    if(!visible.length)svg.append(elem('text',{x:35,y:100,fill:themes.muted,'font-size':18,'font-family':'system-ui'},'Sin coincidencias para los filtros actuales.'));
    $('#diagram-count').textContent=`${visible.length} de ${model.tables.length} entidades · ${drawn} de ${relations.length} relaciones visibles`;
    if(resetView)reset();else viewBox();
  }
  setupTheme(()=>render(false));
  query.addEventListener('input',()=>render());domain.addEventListener('change',()=>render());
  $('#layout').addEventListener('change',ev=>{state.layout=ev.target.value;render()});
  $('#zoom-in').addEventListener('click',()=>zoom(1.25));$('#zoom-out').addEventListener('click',()=>zoom(.8));$('#fit').addEventListener('click',reset);
  $('#lens').addEventListener('click',ev=>{state.focus=!state.focus;ev.currentTarget.setAttribute('aria-pressed',String(state.focus));if(state.focus&&!state.selected)detail.textContent='Selecciona una entidad para aplicar la lente.';render()});
  $('#route').addEventListener('click',ev=>{state.routeMode=!state.routeMode;state.route=[];state.selected=null;ev.currentTarget.setAttribute('aria-pressed',String(state.routeMode));detail.textContent=state.routeMode?'Selecciona dos entidades para calcular una ruta.':'Selecciona una entidad para ver su volumen y sus relaciones.';render()});
  svg.addEventListener('keydown',ev=>{if(ev.target!==svg)return;if(ev.key==='+'||ev.key==='='){ev.preventDefault();zoom(1.25)}else if(ev.key==='-'){ev.preventDefault();zoom(.8)}else if(ev.key==='Escape'){state.selected=null;state.route=[];render(false)}});
  let drag=null;svg.addEventListener('pointerdown',ev=>{if(ev.target.closest('g[role=button]'))return;drag={x:ev.clientX,y:ev.clientY,px:state.panX,py:state.panY};svg.setPointerCapture(ev.pointerId);svg.classList.add('dragging')});
  svg.addEventListener('pointermove',ev=>{if(!drag)return;const rect=svg.getBoundingClientRect();state.panX=drag.px-(ev.clientX-drag.x)*(state.width/state.zoom)/rect.width;state.panY=drag.py-(ev.clientY-drag.y)*(state.height/state.zoom)/rect.height;viewBox()});
  svg.addEventListener('pointerup',()=>{drag=null;svg.classList.remove('dragging')});
  function download(blob,name){const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000)}
  function svgBlob(){const copy=svg.cloneNode(true);copy.setAttribute('xmlns',NS);copy.setAttribute('viewBox',`0 0 ${state.width} ${state.height}`);copy.setAttribute('width',state.width);copy.setAttribute('height',state.height);return new Blob([new XMLSerializer().serializeToString(copy)],{type:'image/svg+xml;charset=utf-8'})}
  $('#export-svg').addEventListener('click',()=>download(svgBlob(),'db-test-diagrama.svg'));
  $('#export-png').addEventListener('click',()=>{const url=URL.createObjectURL(svgBlob()),img=new Image();img.onload=()=>{const ratio=Math.min(2,3000/state.width,6000/state.height),canvas=document.createElement('canvas');canvas.width=Math.max(1,Math.round(state.width*ratio));canvas.height=Math.max(1,Math.round(state.height*ratio));canvas.getContext('2d').drawImage(img,0,0,canvas.width,canvas.height);canvas.toBlob(blob=>{URL.revokeObjectURL(url);if(blob)download(blob,'db-test-diagrama.png');else detail.textContent='No se pudo generar el PNG.'},'image/png')};img.onerror=()=>{URL.revokeObjectURL(url);detail.textContent='No se pudo generar el PNG.'};img.src=url});
  render();
} catch(error) { fail(error); }
