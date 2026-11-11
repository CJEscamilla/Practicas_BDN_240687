import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile, access } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseDump } from './sql-parser.mjs';

const here=dirname(fileURLToPath(import.meta.url)), root=resolve(here,'..'), site=resolve(root,'diccionario-publico');
const source=await readFile(resolve(root,'backups/dicionario.sql'),'utf8');
const generated=JSON.parse(await readFile(resolve(site,'schema.json'),'utf8'));
const fresh=parseDump(source);
const sort=a=>[...a].sort((a,b)=>a.localeCompare(b));

// Independent, line-based audit of this particular mysqldump. It fails closed
// if the dump stops using one CREATE TABLE line / one column per line.
const blocks=[...source.matchAll(/^CREATE TABLE `([^`]+)` \(\r?\n([\s\S]*?)^\) ENGINE=[^\r\n]+;/gm)];
test('every physical CREATE TABLE and column agrees with the source',()=>{
  assert.equal(blocks.length,(source.match(/^CREATE TABLE\b/gm)||[]).length);
  assert.deepEqual(sort(blocks.map(m=>m[1])),sort(generated.tables.map(t=>t.name)));
  for(const [,name,body] of blocks){
    const t=generated.tables.find(x=>x.name===name), lines=body.split(/\r?\n/);
    const cols=lines.map(line=>/^\s*`([^`]+)`\s+(.+?)(?:,)?\s*$/.exec(line)).filter(Boolean);
    assert.deepEqual(cols.map(c=>c[1]),t.columns.map(c=>c.name),name);
    for(const [,col,definition] of cols){
      const c=t.columns.find(x=>x.name===col), raw=definition.replace(/,\s*$/,'');
      if(c.definition!=='[definición reservada por contener un valor predeterminado sensible]') assert.equal(c.definition,String.fromCharCode(96)+col+String.fromCharCode(96)+' '+raw,`${name}.${col} definición`);
      assert.equal(c.nullable,!/\bNOT\s+NULL\b/i.test(raw),`${name}.${col} NULL`);
      assert.equal(c.defaultDeclared,/\bDEFAULT\b/i.test(raw),`${name}.${col} DEFAULT declarado`);
      const d=/\bDEFAULT\s+((?:[bBxX])?'(?:\\.|''|[^'])*'|[^\s,]+)/i.exec(raw);
      if(d && c.default!=='[valor reservado]')assert.equal(c.default,d[1],`${name}.${col} DEFAULT`);
      assert.ok(raw.toLowerCase().startsWith(c.type.toLowerCase()),`${name}.${col} tipo`);
    }
    const indexes=lines.map(l=>l.trim().replace(/,$/,'')).filter(l=>/^(?:PRIMARY KEY|UNIQUE (?:KEY|INDEX)|(?:FULLTEXT |SPATIAL )?(?:KEY|INDEX))\b/i.test(l));
    assert.deepEqual(indexes,t.indexes.map(i=>i.definition),`${name} índices`);
    const checks=lines.map(l=>l.trim().replace(/,$/,'')).filter(l=>/^(?:CONSTRAINT `[^`]+` )?CHECK\b/i.test(l));
    assert.deepEqual(checks,t.checks.map(c=>c.expression),`${name} CHECK`);
    const foreign=lines.map(l=>l.trim().replace(/,$/,'')).filter(l=>/FOREIGN KEY/i.test(l));
    assert.equal(foreign.length,t.foreignKeys.length,`${name} FK`);
    for(const line of foreign){
      const m=/CONSTRAINT `([^`]+)` FOREIGN KEY \(([^)]+)\) REFERENCES `([^`]+)` \(([^)]+)\)(.*)/i.exec(line);assert.ok(m,`${name} FK formato`);
      const f=t.foreignKeys.find(x=>x.name===m[1]);assert.ok(f,m[1]);
      const ids=s=>[...s.matchAll(/`([^`]+)`/g)].map(x=>x[1]);
      assert.deepEqual(f.columns,ids(m[2]));assert.equal(f.target,m[3]);assert.deepEqual(f.references,ids(m[4]));
      for(const action of ['DELETE','UPDATE']) {const match=new RegExp('ON '+action+' (RESTRICT|CASCADE|SET NULL|NO ACTION|SET DEFAULT)','i').exec(m[5]);assert.equal(f[action==='DELETE'?'onDelete':'onUpdate'],match?match[1].toUpperCase():'NO DECLARADO');}
    }
  }
});

test('independent count of VALUES tuples, excluding triggers and procedures',()=>{
  const counts={};
  for(const line of source.split(/\r?\n/)){
    const header=/^INSERT INTO `([^`]+)` VALUES\s*/i.exec(line);if(!header)continue;
    let depth=0,quote=null,n=0;
    for(let i=header[0].length;i<line.length;i++){
      const c=line[i];if(quote){if(c==='\\'){i++;continue}if(c===quote){if(line[i+1]===quote)i++;else quote=null}}
      else if(c==="'"||c==='"'||c==='`')quote=c;
      else if(c==='('){if(depth===0)n++;depth++}else if(c===')')depth--;
    }
    assert.equal(depth,0,header[1]);assert.equal(quote,null,header[1]);counts[header[1]]=(counts[header[1]]||0)+n;
  }
  assert.deepEqual(counts,generated.rowCount.byTable);
  assert.equal(Object.values(counts).reduce((a,b)=>a+b,0),generated.metrics.rows);
});

test('programmable objects independently match dump declarations',()=>{
  const viewNames=[...source.matchAll(/\/\*!50001 VIEW `([^`]+)` AS/gi)].map(m=>m[1]);
  const triggerNames=[...source.matchAll(/\/\*!50003 TRIGGER `([^`]+)`/gi)].map(m=>m[1]);
  const routineNames=[...source.matchAll(/^CREATE DEFINER=[^\r\n]*?\b(PROCEDURE|FUNCTION) `([^`]+)`/gim)];
  assert.deepEqual(sort(viewNames),sort(generated.views.map(x=>x.name)));
  assert.deepEqual(sort(triggerNames),sort(generated.triggers.map(x=>x.name)));
  assert.deepEqual(sort(routineNames.filter(x=>x[1].toUpperCase()==='PROCEDURE').map(x=>x[2])),sort(generated.procedures.map(x=>x.name)));
  assert.deepEqual(sort(routineNames.filter(x=>x[1].toUpperCase()==='FUNCTION').map(x=>x[2])),sort(generated.functions.map(x=>x.name)));
  assert.equal((source.match(/^CREATE(?:\s+DEFINER=[^\r\n]*?)?\s+EVENT\s+`/gim)||[]).length,generated.events.length);
});

test('FK targets and composite pairs resolve without collapsing constraints',()=>{
  for(const t of generated.tables)for(const f of t.foreignKeys){
    const target=generated.tables.find(x=>x.name===f.target);assert.ok(target,`${t.name} → ${f.target}`);
    assert.ok(f.columns.length>0);assert.equal(f.columns.length,f.references.length);
    for(const c of f.columns)assert.ok(t.columns.some(x=>x.name===c));
    for(const c of f.references)assert.ok(target.columns.some(x=>x.name===c));
  }
  assert.ok(generated.tables.some(t=>t.foreignKeys.some(f=>f.columns.length>1)),'el respaldo incluye FK compuestas');
});

test('inconsistent routine columns are surfaced instead of silently invented',()=>{
  for(const name of ['sp_deactivate_user','sp_register_user']){
    const procedure=generated.procedures.find(p=>p.name===name);assert.ok(procedure);
    assert.ok(procedure.warnings.some(w=>w.includes('tb_users.status')),name);
  }
  assert.equal(generated.tables.find(t=>t.name==='tb_users').columns.some(c=>c.name==='status'),false);
});

test('published metrics are reproducible and index categories sum once',()=>{
  assert.deepEqual(generated.metrics,fresh.metrics);
  assert.equal(generated.source.sha256,fresh.source.sha256);
  assert.deepEqual(generated.rowCount.byTable,fresh.rowCount.byTable);
  assert.equal(generated.metrics.physicalIndexes,generated.metrics.primaryIndexes+generated.metrics.uniqueIndexes+generated.metrics.otherIndexes);
  assert.equal(generated.metrics.columns,generated.tables.reduce((n,t)=>n+t.columns.length,0));
  assert.equal(generated.metrics.foreignKeys,generated.tables.reduce((n,t)=>n+t.foreignKeys.length,0));
  assert.deepEqual(generated.limitations,[]);
});

test('SQL tokenizer handles delimiters, escapes and multiline VALUES without storing rows',()=>{
  const sql="CREATE TABLE `a` (`id` int NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB;\n"+
    "INSERT INTO `a` VALUES (1,'comma, ),('),(2,'semi; quote \\\' here'),\n(3,'another');\n"+
    "DELIMITER ;;\n/*!50003 CREATE*/ /*!50017 DEFINER=`redacted`@`localhost`*/ /*!50003 TRIGGER `a_i` AFTER INSERT ON `a` FOR EACH ROW BEGIN INSERT INTO `logs` VALUES (1); END */;;\nDELIMITER ;\n";
  const m=parseDump(sql);assert.equal(m.tables[0].rows,3);assert.equal(m.triggers.length,1);
  assert.equal(JSON.stringify(m).includes('comma, ),('),false);assert.equal(JSON.stringify(m).includes('redacted`@'),false);
  const unsupported=parseDump('CREATE TABLE `a` (`id` int) ENGINE=InnoDB; INSERT INTO `a` SELECT `id` FROM `b`;');
  assert.equal(unsupported.rowCount.complete,false);assert.ok(unsupported.limitations.length);
  assert.throws(()=>parseDump("SET sql_mode='NO_BACKSLASH_ESCAPES';"));
});

test('site pages use relative resources that exist',async()=>{
  for(const page of ['index.html','esquema.html']){
    const html=await readFile(resolve(site,page),'utf8');
    const refs=[...html.matchAll(/(?:href|src)="(\.\/[^"#]+)"/g)].map(x=>x[1]);
    assert.ok(refs.length>=2);for(const ref of refs)await access(resolve(site,ref));
    assert.ok(!/(?:href|src)="\//.test(html));
  }
  await access(resolve(site,'schema.json'));
});

test('CSV and annex cover all fields and objects without dumping row values or definers',async()=>{
  const csv=await readFile(resolve(site,'campos_clasificados.csv'),'utf8');
  const sql=await readFile(resolve(site,'anexo_definiciones.sql'),'utf8');
  const expectedFields=generated.metrics.columns+generated.views.reduce((n,v)=>n+(v.columns||[]).length,0);
  assert.equal(csv.trim().split(/\r?\n/).length-1,expectedFields);
  const tableCount=(sql.match(/^CREATE\s+TABLE\s+`/gim)||[]).length;
  const triggers=(sql.match(/^CREATE\s+TRIGGER\s+`/gim)||[]).length;
  const routines=(sql.match(/^CREATE\s+PROCEDURE\s+`/gim)||[]).length;
  const views=(sql.match(/^CREATE\s+(?:ALGORITHM\s*=\s*\w+\s+)?(?:SQL\s+SECURITY\s+(?:DEFINER|INVOKER)\s+)?VIEW\s+`/gim)||[]).length;
  assert.equal(tableCount,generated.metrics.tables);assert.equal(triggers,generated.metrics.triggers);assert.equal(routines,generated.metrics.procedures);assert.equal(views,generated.metrics.views);
  assert.doesNotMatch(sql,/\bDEFINER\s*=/i);assert.doesNotMatch(JSON.stringify(generated),/\bDEFINER\s*=/i);
  assert.doesNotMatch(csv+sql+JSON.stringify(generated),/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{20,}|\bAKIA[0-9A-Z]{16}\b/);
  for(const line of source.split(/\r?\n/)){
    const head=/^INSERT INTO `[^`]+` VALUES\s*/i.exec(line);if(!head)continue;
    const sample=line.slice(head[0].length,head[0].length+120);
    if(sample.length===120){assert.equal(sql.includes(sample),false,'anexo no debe copiar registros');assert.equal(csv.includes(sample),false);assert.equal(JSON.stringify(generated).includes(sample),false);}
  }
});
