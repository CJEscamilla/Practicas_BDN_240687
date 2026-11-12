import { $, escapeHTML as e, number, loadModel, setupTheme, fillMetrics, fail } from './common.js';

const tag = (text, kind) => `<span class="badge ${kind}">${e(text)}</span>`;
const formatColumns = columns => columns.map(e).join(', ');
function badges(c) {
  return [c.indexes.some(i=>i.kind==='primary') ? tag('PK','pk') : '', c.foreignKeys.length ? tag('FK','fk') : '', c.indexes.some(i=>i.kind==='unique') ? tag('UQ*','uq') : ''].join(' ');
}
function fieldRow(c) {
  const details = [ ['Cantidad',c.quantity],['Composición',c.composition],['Naturaleza',c.nature],['Escala',c.scale],['Dominio',c.domain],['Origen',c.origin],['Puede omitirse',c.omittable],['Evidencia',c.evidence] ];
  return `<tr><td><code>${e(c.name)}</code><br>${badges(c)}</td><td><code>${e(c.type)}</code>${c.autoIncrement?'<br><span class="subtle">AUTO_INCREMENT</span>':''}${c.generated?'<br><span class="subtle">Generada '+(c.generatedStored?'STORED':'VIRTUAL')+'</span>':''}</td><td>${c.nullable?'Sí':'No'}</td><td><code>${c.defaultDeclared?e(c.default):'No declarado'}</code></td><td class="cell-notes">${e(c.explanation)}<details><summary>Clasificación y reglas</summary><dl>${details.map(([k,v])=>`<dt><strong>${e(k)}</strong></dt><dd>${e(v)}</dd>`).join('')}<dt><strong>Definición declarada</strong></dt><dd><code>${e(c.definition)}</code></dd><dt><strong>Índices asociados</strong></dt><dd>${c.indexes.length?c.indexes.map(i=>`${e(i.name)} (${e(i.kind)}: ${formatColumns(i.columns)})`).join('<br>'):'Ninguno declarado'}</dd>${c.onUpdate?`<dt><strong>ON UPDATE</strong></dt><dd>${e(c.onUpdate)}</dd>`:''}</dl></details></td></tr>`;
}
function relationText(fk) {
  const destination = fk.targetUnique ? (fk.optional?'0..1 destino':'1 destino') : 'destino: unicidad no comprobada';
  return `${destination}; destino → origen: ${fk.unique?'0..1':'0..N'}`;
}
function tableCard(t, open) {
  const indexRows = t.indexes.map(i=>`<li><code>${e(i.name)}</code> · ${e(i.kind.toUpperCase())} · <code>(${formatColumns(i.columns)})</code></li>`).join('');
  const checkRows = t.checks.map(c=>`<li><code>${e(c.expression)}</code></li>`).join('');
  const fkRows = t.foreignKeys.map(f=>`<li><code>${e(f.name)}</code>: (${formatColumns(f.columns)}) → <code>${e(f.target)}</code> (${formatColumns(f.references)}); ${e(relationText(f))}; DELETE ${e(f.onDelete)}, UPDATE ${e(f.onUpdate)}</li>`).join('');
  return `<details class="entity" id="tabla-${e(t.name)}" ${open?'open':''}><summary><strong>${e(t.name)}</strong><span class="badge">${e(t.domain)}</span><span class="muted">${number(t.rows)} filas · ${t.columns.length} campos</span></summary><div class="entity-body"><p>${e(t.description)} <span class="subtle">${e(t.descriptionEvidence)}</span></p><div class="tagline"><span>Motor: ${e(t.engine||'No declarado')}</span><span>Charset: ${e(t.charset||'No declarado')}</span><span>Collation: ${e(t.collation||'No declarada')}</span></div><p class="subtle">UQ* indica participación en una clave única; puede ser compuesta y no implica unicidad individual.</p><div class="table-scroll"><table><thead><tr><th>Campo / clave</th><th>Tipo y atributos</th><th>¿NULL?</th><th>DEFAULT</th><th>Descripción / clasificación</th></tr></thead><tbody>${t.columns.map(fieldRow).join('')}</tbody></table></div><div class="grid2" style="margin-top:1rem"><div><h4>Índices físicos</h4><ul class="list">${indexRows||'<li>Ninguno declarado</li>'}</ul></div><div><h4>Claves foráneas</h4><ul class="list">${fkRows||'<li>Ninguna declarada</li>'}</ul></div></div>${checkRows?`<h4>Restricciones CHECK</h4><ul class="list">${checkRows}</ul>`:''}</div></details>`;
}
function renderObjects(m) {
  const actions=x=>x.actions?.length?`Acciones detectadas: ${x.actions.map(a=>`${a.operation} en ${a.table}`).join(', ')}; podrían estar sujetas a condiciones.`:'No se identificaron modificaciones directas a tablas.';
  const sections = [
    ['Vistas',m.views,x=>`Proyección declarada; referencias detectadas: ${x.references.join(', ')||'ninguna identificada'}. Seguridad: ${x.security}. Columnas proyectadas: ${(x.columns||[]).join(', ')||'no determinadas'}.`],
    ['Procedimientos',m.procedures,x=>`${x.description?`${x.description} (${x.descriptionEvidence}) `:''}Parámetros: ${x.parameters.join('; ')||'ninguno'}. Referencias detectadas: ${x.references.join(', ')||'ninguna identificada'}. ${actions(x)} Seguridad: ${x.security}. ${x.containsTransaction?'Contiene instrucciones de transacción.':''} ${x.warnings?.length?'ATENCIÓN: '+x.warnings.join(' '):''}`],
    ['Funciones',m.functions,x=>`${x.description?`${x.description} (${x.descriptionEvidence}) `:''}Parámetros: ${x.parameters.join('; ')||'ninguno'}. Tipo de retorno: ${x.returns||'no interpretado'}. Acceso SQL declarado: ${x.sqlDataAccess||'NO DECLARADO'}. ${x.usesRandom?'Usa RAND para generar resultados aleatorios. ':''}Referencias detectadas: ${x.references.join(', ')||'ninguna identificada'}. ${actions(x)}`],
    ['Triggers',m.triggers,x=>`${x.timing} ${x.event} por fila en ${x.table}. ${actions(x)} ${x.containsSignal?'Puede emitir un error SQL durante una validación.':''} Referencias detectadas: ${x.references.join(', ')||'ninguna identificada'}. ${x.warnings?.length?'ATENCIÓN: '+x.warnings.join(' '):''}`],
    ['Eventos',m.events,x=>`Programación: ${x.schedule}. Referencias detectadas: ${x.references.join(', ')||'ninguna identificada'}.`]
  ];
  $('#objects').innerHTML=sections.map(([label,items,describe])=>`<details class="entity"><summary><strong>${e(label)}</strong><span class="badge">${items.length}</span></summary><div class="entity-body">${items.length?`<ul class="list">${items.map(x=>`<li><code>${e(x.name)}</code> — ${e(describe(x))}</li>`).join('')}</ul>`:'<p class="muted">No se encontró ninguno en el respaldo.</p>'}</div></details>`).join('');
}
try {
  setupTheme();
  const m=await loadModel();
  fillMetrics(m);
  $('#source-name').textContent=m.source.file;
  $('#hash').textContent=m.source.sha256;
  $('#source-chips').innerHTML=[m.source.database,`MySQL ${m.source.serverVersion}`,m.source.charset,m.source.collation,m.source.file].map(x=>`<span class="chip">${e(x||'No declarado')}</span>`).join('');
  $('#total-rows').textContent=number(m.metrics.rows);
  $('#volume-summary').textContent=`${m.metrics.tablesWithRows} tablas con registros · ${m.metrics.tables-m.metrics.tablesWithRows} sin registros representados`;
  $('#volume-table').innerHTML=m.tables.map(t=>`<tr><td><a href="#tabla-${e(t.name)}"><code>${e(t.name)}</code></a></td><td>${number(t.rows)}</td><td>${e(t.domain)}</td></tr>`).join('');
  $('#domain').innerHTML += m.domainNames.map(d=>`<option value="${e(d)}">${e(d)}</option>`).join('');
  $('#notes').innerHTML=m.notes.map(x=>`<li>${e(x)}</li>`).join('');
  renderObjects(m);
  const query=$('#query'), domain=$('#domain');
  function render() {
    const q=query.value.trim().toLocaleLowerCase('es'), selected=domain.value;
    const filtered=m.tables.filter(t=>(!selected||t.domain===selected)&&(!q||JSON.stringify(t).toLocaleLowerCase('es').includes(q)));
    $('#records').innerHTML=filtered.length?filtered.map(t=>tableCard(t,!!q)).join(''):'<p class="empty">No hay coincidencias. Prueba otro término o dominio.</p>';
    $('#table-count').textContent=`${filtered.length} de ${m.tables.length} tablas`;
    const relations=m.tables.flatMap(t=>t.foreignKeys.map(f=>({t,f}))).filter(({t,f})=>(!selected||t.domain===selected||m.tables.find(x=>x.name===f.target)?.domain===selected)&&(!q||JSON.stringify({table:t.name,...f}).toLocaleLowerCase('es').includes(q)));
    $('#relations').innerHTML=relations.length?relations.map(({t,f})=>`<tr><td><code>${e(f.name)}</code></td><td><code>${e(t.name)} (${formatColumns(f.columns)})</code></td><td><code>${e(f.target)} (${formatColumns(f.references)})</code></td><td>${e(relationText(f))}</td><td>${e(f.onDelete)} / ${e(f.onUpdate)}</td></tr>`).join(''):'<tr><td colspan="5" class="muted">Sin relaciones para este filtro.</td></tr>';
  }
  query.addEventListener('input',render);domain.addEventListener('change',render);
  $('#clear').addEventListener('click',()=>{query.value='';domain.value='';render();query.focus()});
  function revealHash() {
    const id=decodeURIComponent(location.hash.slice(1));
    if(!id.startsWith('tabla-'))return;
    const target=document.getElementById(id);
    if(target){target.open=true;target.scrollIntoView({block:'start'});}
  }
  window.addEventListener('hashchange',revealHash);
  render();
  if(location.hash.startsWith('#tabla-'))requestAnimationFrame(revealHash);
} catch(error) { fail(error); }
