export const $ = (selector, root = document) => root.querySelector(selector);
export const escapeHTML = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
export const number = n => new Intl.NumberFormat('es-MX').format(n);
export async function loadModel() {
  const modelUrl = new URL('../schema.json', import.meta.url);
  const revision = new URL(import.meta.url).searchParams.get('v');
  if (revision) modelUrl.searchParams.set('v', revision);
  const response = await fetch(modelUrl, {cache:'no-cache'});
  if (!response.ok) throw new Error(`No se pudo cargar schema.json (HTTP ${response.status})`);
  return response.json();
}
export function setupTheme(onChange = () => {}) {
  const saved = localStorage.getItem('schema-theme');
  if (saved === 'light' || saved === 'dark') document.documentElement.dataset.theme = saved;
  const button = $('#theme');
  const update = () => { const light = document.documentElement.dataset.theme === 'light'; button.textContent = light ? '☾ Tema oscuro' : '☼ Tema claro'; button.setAttribute('aria-label', button.textContent); onChange(); };
  button.addEventListener('click', () => { document.documentElement.dataset.theme = document.documentElement.dataset.theme === 'light' ? 'dark' : 'light'; localStorage.setItem('schema-theme', document.documentElement.dataset.theme); update(); });
  update();
}
export function fail(error) {
  const target = $('#app-error'); target.hidden = false; target.textContent = `No fue posible cargar el inventario: ${error.message}. Abre el sitio mediante GitHub Pages o un servidor local.`;
  console.error(error);
}
export function metrics(model) {
  return [ ['tables','Tablas'],['columns','Columnas'],['foreignKeys','Claves foráneas'],['views','Vistas'],['procedures','Procedimientos'],['functions','Funciones'],['triggers','Triggers'],['events','Eventos'],['physicalIndexes','Índices físicos'] ];
}
export function fillMetrics(model, selector = '#metrics') {
  $(selector).innerHTML = metrics(model).map(([key,label])=>`<article class="kpi"><strong data-metric="${key}">${number(model.metrics[key])}</strong><span>${escapeHTML(label)}</span></article>`).join('');
}
