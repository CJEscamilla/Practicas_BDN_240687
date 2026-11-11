import {spawn} from 'node:child_process';
import {writeFile, mkdir, readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const root=resolve('.archify/erd-db-test');
const proc=spawn('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',['--headless=new','--disable-gpu','--no-first-run','--no-default-browser-check','--remote-debugging-port=19333',`--user-data-dir=${root}/browser-profile`,'about:blank'],{windowsHide:true,stdio:'ignore'});
let ws,seq=0;const pending=new Map(),events=[];
const pause=ms=>new Promise(r=>setTimeout(r,ms));
try{
let pages;for(let i=0;i<60;i++){try{pages=await(await fetch('http://127.0.0.1:19333/json')).json();break}catch{await pause(150)}}
if(!pages)throw new Error('No se pudo iniciar Edge para verificar el visor');
ws=new WebSocket(pages.find(p=>p.type==='page').webSocketDebuggerUrl);await new Promise((r,j)=>{ws.onopen=r;ws.onerror=j});ws.onmessage=e=>{const m=JSON.parse(e.data);if(m.id){const p=pending.get(m.id);pending.delete(m.id);m.error?p?.reject(new Error(JSON.stringify(m.error))):p?.resolve(m.result)}else events.push(m)};
const send=(method,params={})=>new Promise((resolve,reject)=>{const id=++seq;pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}))});
const evaluate=async expression=>{const r=await send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true,userGesture:true});if(r.exceptionDetails)throw new Error(JSON.stringify(r.exceptionDetails));return r.result.value};
await send('Runtime.enable');await send('Page.enable');await send('Emulation.setDeviceMetricsOverride',{width:1440,height:900,deviceScaleFactor:1,mobile:false});
await send('Page.navigate',{url:pathToFileURL(resolve('practica03/modelo-eer.html')).href});for(let i=0;i<50;i++){if(await evaluate('document.readyState==="complete" && typeof state!=="undefined"'))break;await pause(100)}
const checks=[];
const check=(name,value)=>{assert.ok(value,name);checks.push(name)};
check('16 tablas, 137 columnas, 20 FK y 23 segmentos',await evaluate('DB.tables.length===16 && DB.tables.reduce((n,t)=>n+t.columns.length,0)===137 && DB.relations.length===20 && document.querySelectorAll(".edge:not(.hit)").length===23'));
check('10,130 filas exactas del snapshot',await evaluate('DB.tables.reduce((n,t)=>n+t.rows,0)===10130 && $("rowsMetric").textContent==="10,130"'));
check('Sin desbordamiento de página en escritorio',await evaluate('document.documentElement.scrollWidth===innerWidth && document.documentElement.scrollHeight===innerHeight'));
await send('Page.captureScreenshot',{format:'png',captureBeyondViewport:false}).then(r=>writeFile(root+'/visor-desktop.png',Buffer.from(r.data,'base64')));
await evaluate('document.querySelector("[data-filter=data]").click()');check('Con datos: 4 tablas, conteo de filas conservado',await evaluate('state.visible.length===4 && $("rowsMetric").textContent==="10,130"'));
await evaluate('document.querySelector("[data-filter=empty]").click()');check('Vacías: 12 tablas y cero filas',await evaluate('state.visible.length===12 && $("rowsMetric").textContent==="0"'));
await evaluate('document.querySelector("[data-filter=all]").click(); $("search").value="decimal"; $("search").dispatchEvent(new Event("input"))');check('Búsqueda por tipo decimal',await evaluate('state.visible.length>0 && state.visible.every(t=>t.columns.some(c=>c.type.includes("decimal")))'));
await evaluate('$("search").value="no_existe_zz"; $("search").dispatchEvent(new Event("input"))');check('Estado sin coincidencias',await evaluate('state.visible.length===0 && $("empty").style.display==="block"'));
await evaluate('$("search").value=""; $("search").dispatchEvent(new Event("input")); $("collapse").click()');check('Colapso global',await evaluate('state.collapsed.size===16 && document.querySelectorAll(".card.collapsed").length===16'));
await evaluate('$("collapse").click(); $("layout").value="grid"; $("layout").dispatchEvent(new Event("change"))');
check('Grid sin solapamientos',await evaluate('state.visible.every((a,i)=>state.visible.slice(i+1).every(b=>{const p=state.positions[a.name],q=state.positions[b.name];return p.x+W<=q.x||q.x+W<=p.x||p.y+height(a)<=q.y||q.y+height(b)<=p.y}))'));
await evaluate('showRelation(DB.relations.find(r=>r.columns.length===2))');check('Detalle de FK compuesta',await evaluate('$("detail").textContent.includes("Llave foránea compuesta")'));
await evaluate('focusTable("tb_buyer_orders"); select({table:"tb_buyer_orders",column:"status"})');check('Definición enum precisa',await evaluate('$("detail").textContent.includes("enum(\'pending\',\'confirmed\',\'processing\',\'shipped\',\'delivered\',\'cancelled\')")'));
await send('Page.captureScreenshot',{format:'png',captureBeyondViewport:false}).then(r=>writeFile(root+'/visor-detail.png',Buffer.from(r.data,'base64')));
await evaluate('$("closeInspector").click(); document.querySelector("[data-key=pk]").click()');check('Leyenda interactiva',await evaluate('state.key==="pk" && document.querySelectorAll(".column.selected").length===16'));
await send('Input.dispatchKeyEvent',{type:'keyDown',key:'k',code:'KeyK',modifiers:2});await send('Input.dispatchKeyEvent',{type:'keyUp',key:'k',code:'KeyK',modifiers:2});check('Ctrl K enfoca búsqueda',await evaluate('document.activeElement===$("search")'));
await evaluate('$("search").blur();fit()');const oldZoom=await evaluate('state.z');await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:600,y:450,deltaX:0,deltaY:-200});await pause(100);check('Zoom con rueda',await evaluate('state.z')>oldZoom);
const pan=await evaluate('({x:state.x,y:state.y})');await send('Input.dispatchMouseEvent',{type:'mousePressed',x:8,y:400,button:'left',clickCount:1});await send('Input.dispatchMouseEvent',{type:'mouseMoved',x:70,y:450,button:'left',buttons:1});await send('Input.dispatchMouseEvent',{type:'mouseReleased',x:70,y:450,button:'left',clickCount:1});check('Paneo por arrastre',await evaluate(`state.x!==${pan.x} || state.y!==${pan.y}`));
await evaluate('focusTable("tb_products")');const rect=await evaluate('(()=>{const r=nodes.get("tb_products").querySelector(".table-head").getBoundingClientRect();return{x:r.x+70,y:r.y+25,p:state.positions.tb_products.x}})()');await send('Input.dispatchMouseEvent',{type:'mousePressed',x:rect.x,y:rect.y,button:'left',clickCount:1});await send('Input.dispatchMouseEvent',{type:'mouseMoved',x:rect.x+65,y:rect.y+25,button:'left',buttons:1});await send('Input.dispatchMouseEvent',{type:'mouseReleased',x:rect.x+65,y:rect.y+25,button:'left',clickCount:1});check('Movimiento individual de tabla',await evaluate(`state.positions.tb_products.x!==${rect.p}`));
await evaluate('miniNavigate({clientX:$("minimap").getBoundingClientRect().left+20,clientY:$("minimap").getBoundingClientRect().top+20})');check('Navegación con minimapa',await evaluate('Number.isFinite(state.x)&&Number.isFinite(state.y)'));
await mkdir(root+'/exports',{recursive:true});await evaluate('window.__exports=[]; download=(blob,name)=>window.__exports.push({blob,name}); $("svgExport").click(); $("pngExport").click()');for(let i=0;i<100;i++){if(await evaluate('!$("pngExport").disabled'))break;await pause(100)}
const exported=await evaluate('(async()=>{const out=[]; for(const e of window.__exports){const bytes=new Uint8Array(await e.blob.arrayBuffer()); let binary="";for(const byte of bytes)binary+=String.fromCharCode(byte);out.push({name:e.name,base64:btoa(binary)})}return out})()');for(const e of exported)await writeFile(root+'/exports/'+e.name,Buffer.from(e.base64,'base64'));
const png=await readFile(root+'/exports/db-test-eer.png');const svg=await readFile(root+'/exports/db-test-eer.svg','utf8');check('Generación SVG y PNG real en file:// (Blob capturado)',png.subarray(1,4).toString()==='PNG' && svg.includes('<svg')&&!svg.includes('foreignObject'));
await send('Emulation.setDeviceMetricsOverride',{width:640,height:820,deviceScaleFactor:1,mobile:false});await pause(200);check('Sin desbordamiento de página a 640px',await evaluate('document.documentElement.scrollWidth===innerWidth && document.documentElement.scrollHeight===innerHeight'));
check('Sin errores JS de ejecución',!events.some(e=>e.method==='Runtime.exceptionThrown'));
await writeFile(root+'/verification.json',JSON.stringify({passed:checks.length,checks,browser:'Microsoft Edge headless',url:'file://',errors:events.filter(e=>e.method==='Runtime.exceptionThrown')},null,2));console.log(JSON.stringify({passed:checks.length,checks},null,2));
await send('Browser.close');
}finally{ws?.close();proc.kill()}
