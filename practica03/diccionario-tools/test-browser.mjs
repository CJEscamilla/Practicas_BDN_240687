// Optional developer-only regression suite. Requires Playwright and a local
// browser; the published site itself has no dependencies or backend.
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const here=dirname(fileURLToPath(import.meta.url));
const schema=JSON.parse(await readFile(resolve(here,'../diccionario-publico/schema.json'),'utf8'));
const base=process.env.DOCS_BASE_URL||'http://127.0.0.1:4173/Practicas_BDN_240687/';
const browser=await chromium.launch({headless:true});
const page=await browser.newPage({viewport:{width:1440,height:900},acceptDownloads:true});
const errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
test.after(async()=>browser.close());

test('dashboard and search use the shared schema',async()=>{
  await page.goto(base);await page.waitForSelector('[data-metric="tables"]');
  for(const key of ['tables','columns','foreignKeys','views','procedures','functions','triggers','events','physicalIndexes']) {
    const value=await page.locator(`[data-metric="${key}"]`).textContent();assert.equal(Number(value.replace(/\D/g,'')),schema.metrics[key],key);
  }
  await page.locator('#query').fill('SKU');assert.ok((await page.locator('#table-count').textContent()).startsWith('3 de'));
  assert.equal(await page.locator('#tabla-tb_products').count(),1);
  await page.locator('#query').fill('NO_EXISTE_12345');assert.match(await page.locator('#records').textContent(),/No hay coincidencias/);
  await page.locator('#clear').click();await page.locator('#domain').selectOption({label:'Catálogo'});assert.match(await page.locator('#table-count').textContent(),/^5 de/);
  await page.locator('#theme').click();assert.equal(await page.locator('html').getAttribute('data-theme'),'light');
  await page.goto(base+'index.html#tabla-tb_products');await page.waitForSelector('#tabla-tb_products[open]');
});

test('diagram filtering, keyboard selection, zoom and route',async()=>{
  await page.goto(base+'esquema.html');await page.waitForSelector('#diagram g[data-entity]');
  assert.equal(await page.locator('#diagram g[data-entity]').count(),schema.metrics.tables);
  const before=await page.locator('#diagram').getAttribute('viewBox');await page.locator('#zoom-in').click();assert.notEqual(await page.locator('#diagram').getAttribute('viewBox'),before);
  await page.locator('#domain').selectOption({label:'Catálogo'});assert.equal(await page.locator('#diagram g[data-entity]').count(),5);
  await page.locator('g[data-entity="tb_products"]').press('Enter');assert.match(await page.locator('#diagram-detail').textContent(),/15,008/);
  await page.locator('#lens').click();assert.match(await page.locator('#diagram-count').textContent(),/^4 de/);await page.locator('#lens').click();
  await page.locator('#layout').selectOption('fixed');await page.locator('#route').click();
  await page.locator('g[data-entity="tb_products"]').click();await page.locator('g[data-entity="tbc_categories"]').click();assert.match(await page.locator('#diagram-detail').textContent(),/tbd_products_categories/);
  await page.locator('#query').fill('no_existe_12345');assert.match(await page.locator('#diagram-count').textContent(),/^0 de/);
});

test('SVG and PNG downloads contain valid graphics',async()=>{
  await page.locator('#query').fill('');await page.locator('#route').click();
  const svgPromise=page.waitForEvent('download');await page.locator('#export-svg').click();const svg=await readFile(await (await svgPromise).path(),'utf8');
  assert.ok(await page.evaluate(text=>{const doc=new DOMParser().parseFromString(text,'image/svg+xml');return doc.documentElement.localName==='svg'&&!doc.querySelector('parsererror')},svg));
  const pngPromise=page.waitForEvent('download');await page.locator('#export-png').click();const png=await readFile(await (await pngPromise).path());
  assert.deepEqual([...png.subarray(0,8)],[137,80,78,71,13,10,26,10]);assert.ok(png.readUInt32BE(16)>0&&png.readUInt32BE(20)>0);
});

test('responsive pages load at desktop, tablet and mobile sizes without errors',async()=>{
  for(const viewport of [{width:1440,height:900},{width:768,height:1024},{width:390,height:844}]){
    await page.setViewportSize(viewport);
    for(const path of ['', 'esquema.html']){
      await page.goto(base+path);await page.waitForSelector('[data-metric="tables"]');
      assert.equal(await page.locator('#app-error').isHidden(),true);
      assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth));
    }
  }
  assert.deepEqual(errors,[]);
});
