import test from 'node:test';
import assert from 'node:assert/strict';

const base=process.env.DOCS_BASE_URL||'http://127.0.0.1:4173/Practicas_BDN_240687/';
test('Pages-like subdirectory serves all resources with matching dashboard data',async()=>{
  const assets=['index.html','esquema.html','schema.json','campos_clasificados.csv','anexo_definiciones.sql','assets/app.css','assets/common.js','assets/dictionary.js','assets/diagram.js'];
  const responses=await Promise.all(assets.map(async path=>({path,response:await fetch(new URL(path,base))})));
  for(const {path,response} of responses)assert.equal(response.status,200,path);
  const schema=await responses.find(x=>x.path==='schema.json').response.json();
  assert.equal(schema.metrics.tables,schema.tables.length);
  assert.equal(schema.metrics.columns,schema.tables.reduce((n,t)=>n+t.columns.length,0));
  assert.equal(schema.metrics.foreignKeys,schema.tables.reduce((n,t)=>n+t.foreignKeys.length,0));
  for(const page of ['index.html','esquema.html']){
    const html=await responses.find(x=>x.path===page).response.text();
    assert.match(html,/id="metrics"/);assert.doesNotMatch(html,/(?:href|src)="\//);
  }
});
