import { $, escapeHTML as e, number, loadModel, setupTheme, fillMetrics, fail } from './common.js?v=e375ff3c';

// La huella impide mostrar un diagrama generado para otro respaldo.
const sourceHash='e375ff3ca3ce32dbcad20d65e2d7b22d130e292159f7d30013f47f971ae5c512';
const files={
  '':'mapa-archify.html',
  'Identidad':'mapa-archify-identidad.html',
  'Catálogo':'mapa-archify-catalogo.html',
  'Compra':'mapa-archify-compra.html',
  'Pagos':'mapa-archify-pagos.html',
  'Posventa':'mapa-archify-posventa.html',
  'Auditoría':'mapa-archify-auditoria.html'
};
const columns=items=>items.map(e).join(', ');
const relationship=f=>`${f.targetUnique?(f.optional?'0..1 destino':'1 destino'):'destino: unicidad no comprobada'}; destino → origen: ${f.unique?'0..1':'0..N'}`;
try {
  setupTheme();
  const model=await loadModel();
  fillMetrics(model);
  $('#map-source').innerHTML=[model.source.database,`MySQL ${model.source.serverVersion}`,model.source.file,'ARCHIFY'].map(x=>`<span class="chip">${e(x||'No declarado')}</span>`).join('');
  const domain=$('#map-domain'), frame=$('#map-frame'), link=$('#open-map'), status=$('#map-status');
  if(model.source.sha256!==sourceHash){
    frame.hidden=true;
    link.hidden=true;
    domain.disabled=true;
    status.textContent='El respaldo del diccionario cambió. Es necesario regenerar el mapa antes de mostrarlo.';
  }else{
    function render(){
      const selected=domain.value;
      const url=`./mapas-archify/${files[selected]}?v=${sourceHash.slice(0,8)}`;
      frame.src=url;
      link.href=url;
      status.textContent=selected?`Vista ${selected}: incluye sus tablas y las tablas referenciadas.`:'Vista global: todas las tablas y relaciones declaradas.';
      const tables=model.tables.filter(t=>!selected||t.domain===selected);
      $('#map-rows').innerHTML=tables.map(t=>`<tr><td><a href="./index.html#tabla-${encodeURIComponent(t.name)}"><code>${e(t.name)}</code></a></td><td>${e(t.domain)}</td><td>${number(t.rows)}</td></tr>`).join('');
      const fks=tables.flatMap(t=>t.foreignKeys.map(f=>({t,f})));
      $('#map-relations').innerHTML=fks.length?fks.map(({t,f})=>`<tr><td><code>${e(f.name)}</code></td><td><code>${e(t.name)} (${columns(f.columns)})</code></td><td><code>${e(f.target)} (${columns(f.references)})</code></td><td>${e(relationship(f))}</td><td>${e(f.onDelete)} / ${e(f.onUpdate)}</td></tr>`).join(''):'<tr><td colspan="5">No hay claves foráneas de origen en este dominio.</td></tr>';
    }
    domain.addEventListener('change',render);
    render();
  }
}catch(error){fail(error)}
