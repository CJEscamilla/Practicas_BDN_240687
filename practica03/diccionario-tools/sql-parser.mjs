/** MySQL dump reader. Never executes SQL or stores INSERT values in its result. */
import { createHash } from 'node:crypto';

const idPattern = '`((?:``|[^`])+)`';
const unquoteId = s => s.replace(/``/g, '`');

// MySQL client DELIMITER is not SQL. Executable comments are kept intact here;
// their contents are expanded only after the full statement boundary is found.
export function* statements(sql) {
  let delimiter = ';', start = 0, i = 0, line = 1, startLine = 1, lineStart = true;
  while (i < sql.length) {
    if (lineStart) {
      const directive = /^[ \t]*DELIMITER[ \t]+(\S+)[ \t]*(?:\r?\n|$)/i.exec(sql.slice(i, i + 200));
      if (directive) {
        delimiter = directive[1];
        const length = directive[0].length;
        line += (directive[0].match(/\n/g) || []).length;
        i += length; start = i; startLine = line; lineStart = true;
        continue;
      }
    }
    const c = sql[i], n = sql[i + 1];
    if (c === "'" || c === '"' || c === '`') {
      const quote = c; i++; lineStart = false;
      let closed = false;
      while (i < sql.length) {
        if (sql[i] === '\n') { line++; lineStart = true; } else lineStart = false;
        if (sql[i] === '\\') { if (sql[i + 1] === '\n') line++; i += 2; continue; }
        if (sql[i] === quote) {
          if (sql[i + 1] === quote) { i += 2; continue; }
          i++; closed = true; break;
        }
        i++;
      }
      if (!closed) throw new Error(`Cadena o identificador sin cierre cerca de línea ${line}`);
      continue;
    }
    if (c === '/' && n === '*') {
      const end = sql.indexOf('*/', i + 2);
      if (end < 0) throw new Error(`Comentario sin cierre cerca de línea ${line}`);
      const chunk = sql.slice(i, end + 2); line += (chunk.match(/\n/g) || []).length;
      lineStart = chunk.endsWith('\n'); i = end + 2; continue;
    }
    if (c === '#' || (c === '-' && n === '-' && /\s/.test(sql[i + 2] || ' '))) {
      const end = sql.indexOf('\n', i);
      if (end < 0) { i = sql.length; break; }
      i = end; continue;
    }
    if (sql.startsWith(delimiter, i)) {
      yield { text: sql.slice(start, i), line: startLine };
      i += delimiter.length; start = i; startLine = line; lineStart = false; continue;
    }
    if (c === '\n') { line++; lineStart = true; }
    else if (c !== '\r' && c !== ' ' && c !== '\t') lineStart = false;
    i++;
  }
  const tail = sql.slice(start).replace(/--[^\n]*|#[^\n]*|\/\*[\s\S]*?\*\//g, '').trim();
  if (tail) throw new Error(`Sentencia final sin delimitador cerca de línea ${startLine}`);
}

// Unwrap MySQL version comments while leaving quoted data untouched. Ordinary
// comments and dump headers are discarded. No data values are returned.
export function cleanStatement(text) {
  let result = '', i = 0;
  while (i < text.length) {
    const c = text[i], n = text[i + 1];
    if (c === "'" || c === '"' || c === '`') {
      const start = i++, quote = c;
      while (i < text.length) {
        if (text[i] === '\\') { i += 2; continue; }
        if (text[i] === quote) { if (text[i + 1] === quote) { i += 2; continue; } i++; break; }
        i++;
      }
      result += text.slice(start, i); continue;
    }
    if (c === '/' && n === '*') {
      const end = text.indexOf('*/', i + 2);
      if (end < 0) throw new Error('Comentario SQL incompleto');
      const inner = text.slice(i + 2, end);
      result += inner.startsWith('!') ? ' ' + inner.replace(/^!\d{5,6}\s*/, '') + ' ' : ' ';
      i = end + 2; continue;
    }
    if (c === '#' || (c === '-' && n === '-' && /\s/.test(text[i + 2] || ' '))) {
      let end = text.indexOf('\n', i); if (end < 0) end = text.length;
      result += ' '; i = end; continue;
    }
    const next = text.slice(i).search(/['"`/#-]/);
    const end = next < 0 ? text.length : (next === 0 ? i + 1 : i + next);
    result += text.slice(i, end); i = end;
  }
  return result.trim();
}

export function matchingParen(s, start) {
  if (s[start] !== '(') throw new Error('Se esperaba paréntesis de apertura');
  let depth = 0, quote = null;
  for (let i = start; i < s.length; i++) {
    const c = s[i];
    if (quote) {
      if (c === '\\') { i++; continue; }
      if (c === quote) { if (s[i + 1] === quote) i++; else quote = null; }
    } else if (c === "'" || c === '"' || c === '`') quote = c;
    else if (c === '(') depth++;
    else if (c === ')' && --depth === 0) return i;
  }
  throw new Error('Paréntesis SQL sin cierre');
}

export function splitTop(s) {
  const out = []; let start = 0, quote = null, depth = 0;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (quote) {
      if (c === '\\') { i++; continue; }
      if (c === quote) { if (s[i + 1] === quote) i++; else quote = null; }
    } else if (c === "'" || c === '"' || c === '`') quote = c;
    else if (c === '(') depth++;
    else if (c === ')') depth--;
    else if (c === ',' && depth === 0) { out.push(s.slice(start, i).trim()); start = i + 1; }
  }
  if (quote || depth !== 0) throw new Error('Elemento SQL incompleto');
  if (s.slice(start).trim()) out.push(s.slice(start).trim());
  return out;
}

function idList(s) { return [...s.matchAll(/`((?:``|[^`])+)`/g)].map(m => unquoteId(m[1])); }
function listAfter(s, start) {
  const open = s.indexOf('(', start); if (open < 0) throw new Error('Lista de columnas ausente');
  const close = matchingParen(s, open);
  return { values: idList(s.slice(open + 1, close)), close };
}
function readValue(s, offset) {
  let i = offset; while (/\s/.test(s[i] || '') && i < s.length) i++;
  const start = i;
  if (/^[bBxX]$/.test(s[i] || '') && (s[i + 1] === "'" || s[i + 1] === '"')) i++;
  if (s[i] === "'" || s[i] === '"') {
    const q = s[i++];
    while (i < s.length) { if (s[i] === '\\') { i += 2; continue; } if (s[i] === q) { if (s[i+1] === q) { i += 2; continue; } i++; break; } i++; }
  } else if (s[i] === '(') i = matchingParen(s, i) + 1;
  else { while (i < s.length && !/\s|,/.test(s[i])) i++; }
  return s.slice(start, i);
}

function parseColumn(part) {
  const m = new RegExp('^' + idPattern + '\\s+', 'i').exec(part);
  if (!m) throw new Error('Definición de columna no reconocida');
  const name = unquoteId(m[1]), rest = part.slice(m[0].length);
  const tm = /^[a-zA-Z]+(?:\s+(?:precision|varying))?/i.exec(rest);
  if (!tm) throw new Error(`Tipo no reconocido en columna ${name}`);
  let end = tm[0].length;
  if (rest[end] === '(') end = matchingParen(rest, end) + 1;
  const modifier = /^(?:\s+(?:unsigned|zerofill))+/i.exec(rest.slice(end)); if (modifier) end += modifier[0].length;
  const type = rest.slice(0, end), tail = rest.slice(end);
  const defaultMatch = /\bDEFAULT\b/i.exec(tail);
  const rawDefault = defaultMatch ? readValue(tail, defaultMatch.index + defaultMatch[0].length) : null;
  const sensitiveDefault = /pass(word)?|secret|token|api_?key/i.test(name) && rawDefault !== null && !/^null$/i.test(rawDefault);
  const generated = /\bGENERATED\s+ALWAYS\b/i.test(tail);
  const generatedMatch = /\bGENERATED\s+ALWAYS\s+AS\s*\(/i.exec(tail);
  const generatedOpen = generatedMatch ? tail.indexOf('(', generatedMatch.index) : -1;
  const commentMatch = /\bCOMMENT\s+('(?:\\.|''|[^'])*')/i.exec(tail);
  return {
    name, type, nullable: !/\bNOT\s+NULL\b/i.test(tail), autoIncrement: /\bAUTO_INCREMENT\b/i.test(tail),
    default: sensitiveDefault ? '[valor reservado]' : rawDefault,
    defaultDeclared: !!defaultMatch, generated,
    generatedStored: generated ? /\bSTORED\b/i.test(tail) : null,
    generatedExpression: generatedOpen >= 0 ? tail.slice(generatedOpen, matchingParen(tail, generatedOpen) + 1) : null,
    definition: sensitiveDefault ? '[definición reservada por contener un valor predeterminado sensible]' : part,
    onUpdate: /\bON\s+UPDATE\s+([^\s,]+)/i.exec(tail)?.[1] || null,
    charset: /\bCHARACTER\s+SET\s+(\w+)/i.exec(tail)?.[1] || null,
    collation: /\bCOLLATE\s+(\w+)/i.exec(tail)?.[1] || null,
    comment: commentMatch ? commentMatch[1].slice(1, -1).replace(/''/g, "'") : null,
    // Classification is inferred, never presented as a database constraint.
  };
}

function parseTable(stmt, line) {
  const m = new RegExp('^CREATE\\s+TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?' + idPattern + '\\s*\\(', 'i').exec(stmt);
  if (!m) throw new Error(`CREATE TABLE no reconocido en línea ${line}`);
  const name = unquoteId(m[1]), open = stmt.indexOf('(', m[0].length - 1), close = matchingParen(stmt, open);
  const opts = stmt.slice(close + 1), table = { name, columns: [], indexes: [], foreignKeys: [], checks: [], unsupported: [],
    engine: /\bENGINE\s*=\s*(\w+)/i.exec(opts)?.[1] || null,
    charset: /\b(?:DEFAULT\s+)?CHARSET\s*=\s*(\w+)/i.exec(opts)?.[1] || null,
    collation: /\bCOLLATE\s*=\s*(\w+)/i.exec(opts)?.[1] || null, line };
  for (const part of splitTop(stmt.slice(open + 1, close))) {
    if (part.startsWith('`')) { table.columns.push(parseColumn(part)); continue; }
    let f = new RegExp('^(?:CONSTRAINT\\s+' + idPattern + '\\s+)?FOREIGN\\s+KEY\\s*(?:' + idPattern + '\\s*)?\\(', 'i').exec(part);
    if (f) {
      const a = listAfter(part, f[0].length - 1);
      const ref = new RegExp('\\bREFERENCES\\s+(?:' + idPattern + '\\s*\\.\\s*)?' + idPattern + '\\s*\\(', 'i').exec(part.slice(a.close + 1));
      if (!ref) throw new Error(`REFERENCES no reconocido en ${name}`);
      const refOffset = a.close + 1 + ref.index, b = listAfter(part, refOffset + ref[0].length - 1);
      const actions = part.slice(b.close + 1);
      table.foreignKeys.push({ name: f[1] ? unquoteId(f[1]) : null, columns: a.values,
        targetSchema: ref[1] ? unquoteId(ref[1]) : null, target: unquoteId(ref[2]), references: b.values,
        onDelete: /\bON\s+DELETE\s+(RESTRICT|CASCADE|SET\s+NULL|NO\s+ACTION|SET\s+DEFAULT)/i.exec(actions)?.[1].toUpperCase() || 'NO DECLARADO',
        onUpdate: /\bON\s+UPDATE\s+(RESTRICT|CASCADE|SET\s+NULL|NO\s+ACTION|SET\s+DEFAULT)/i.exec(actions)?.[1].toUpperCase() || 'NO DECLARADO' });
      continue;
    }
    const ix = /^(PRIMARY\s+KEY|UNIQUE\s+(?:KEY|INDEX)|(?:FULLTEXT\s+|SPATIAL\s+)?(?:KEY|INDEX))\b/i.exec(part);
    if (ix) {
      const before = part.slice(ix[0].length, part.indexOf('('));
      const foundName = /`((?:``|[^`])+)`/.exec(before), list = listAfter(part, ix[0].length);
      if (!list.values.length) table.unsupported.push('Índice con expresión sin columnas identificables');
      table.indexes.push({ name: foundName ? unquoteId(foundName[1]) : /^PRIMARY/i.test(ix[0]) ? 'PRIMARY' : null,
        kind: /^PRIMARY/i.test(ix[0]) ? 'primary' : /^UNIQUE/i.test(ix[0]) ? 'unique' : 'index',
        columns: list.values, definition: part });
      continue;
    }
    const check = /^(?:CONSTRAINT\s+`([^`]+)`\s+)?CHECK\s*\(/i.exec(part);
    if (check) { table.checks.push({ name: check[1] || null, expression: part }); continue; }
    table.unsupported.push('Definición de tabla no interpretada: ' + part.slice(0, 120));
  }
  return table;
}

function countValues(rest) {
  let i = 0, count = 0;
  while (i < rest.length) {
    while (i < rest.length && /\s|,/.test(rest[i])) i++;
    if (i >= rest.length) break;
    if (rest[i] !== '(') return { count, complete: false };
    i = matchingParen(rest, i) + 1; count++;
  }
  return { count, complete: count > 0 };
}

function parseInsert(stmt) {
  const m = new RegExp('^INSERT\\s+(IGNORE\\s+)?INTO\\s+(?:' + idPattern + '\\s*\\.\\s*)?' + idPattern + '\\s*', 'i').exec(stmt);
  if (!m) return null;
  let i = m[0].length;
  if (stmt[i] === '(') i = matchingParen(stmt, i) + 1;
  const values = /^\s*VALUES?\s*/i.exec(stmt.slice(i));
  if (!values) return { table: unquoteId(m[3]), complete: false, reason: 'INSERT sin VALUES' };
  const r = countValues(stmt.slice(i + values[0].length));
  return { table: unquoteId(m[3]), count: r.count, complete: r.complete && !m[1], reason: m[1] ? 'INSERT IGNORE no permite conocer filas aceptadas sin ejecutar' : r.complete ? null : 'cláusula posterior o valores no interpretados' };
}

export function removeDefiner(s) { return s.replace(/\bDEFINER\s*=\s*(?:`(?:``|[^`])+`|'(?:''|[^'])*'|[^\s@]+)\s*@\s*(?:`(?:``|[^`])+`|'(?:''|[^'])*'|[^\s]+)\s*/ig, ''); }
function extractReferences(s) {
  const refs = new Set();
  const withoutStrings = s.replace(/'(?:\\.|''|[^'])*'|"(?:\\.|""|[^"])*"/g, "''");
  for (const m of withoutStrings.matchAll(/\b(?:FROM|JOIN|UPDATE|INTO)\s+((?:(?:`[^`]+`|[a-z_][\w$]*)\s*\.\s*)?(?:`[^`]+`|[a-z_][\w$]*))/gi)) refs.add(m[1].replace(/`|\s/g, ''));
  return [...refs].sort();
}
function extractActions(s) {
  const withoutStrings = s.replace(/'(?:\\.|''|[^'])*'|"(?:\\.|""|[^"])*"/g, "''");
  const seen = new Set(), actions = [];
  for (const m of withoutStrings.matchAll(/\b(INSERT\s+(?:IGNORE\s+)?INTO|UPDATE|DELETE\s+FROM)\s+((?:(?:`[^`]+`|[a-z_][\w$]*)\s*\.\s*)?(?:`[^`]+`|[a-z_][\w$]*))/gi)) {
    const operation = /^INSERT/i.test(m[1]) ? 'INSERT' : /^UPDATE/i.test(m[1]) ? 'UPDATE' : 'DELETE';
    const table = m[2].replace(/`|\s/g, ''), key = operation + ':' + table;
    if (!seen.has(key)) { seen.add(key); actions.push({ operation, table }); }
  }
  return actions;
}
function extractColumnUses(s) {
  const text=s.replace(/'(?:\\.|''|[^'])*'|"(?:\\.|""|[^"])*"/g, "''"), result=[];
  const insert=/\bINSERT\s+(?:IGNORE\s+)?INTO\s+`?([a-z_][\w$]*)`?\s*\(([^)]*)\)/gi;
  for(const m of text.matchAll(insert)) result.push({table:m[1],columns:splitTop(m[2]).map(x=>x.trim().replace(/^`|`$/g,'')),operation:'INSERT'});
  const update=/\bUPDATE\s+`?([a-z_][\w$]*)`?\s+SET\s+([\s\S]*?)(?=\bWHERE\b|;)/gi;
  for(const m of text.matchAll(update)) {
    const columns=splitTop(m[2]).map(x=>/^\s*`?([a-z_][\w$]*)`?\s*=/i.exec(x)?.[1]).filter(Boolean);
    result.push({table:m[1],columns,operation:'UPDATE'});
  }
  return result;
}

export function parseDump(sql, { sourceName = 'dicionario.sql' } = {}) {
  if (/\bNO_BACKSLASH_ESCAPES\b/i.test(sql) || /\bANSI_QUOTES\b/i.test(sql)) throw new Error('El modo SQL requiere un análisis de comillas diferente');
  const header = sql.slice(0, 4000), version = /Server version\s+([^\s]+)/i.exec(header)?.[1] || null;
  const db = /CREATE\s+DATABASE(?:\s+\/\*![\s\S]*?\*\/)?\s+`([^`]+)`/i.exec(sql)?.[1] || null;
  const charset = /CREATE\s+DATABASE[^;]*\bCHARACTER\s+SET\s+(\w+)/i.exec(sql)?.[1] || null;
  const collation = /CREATE\s+DATABASE[^;]*\bCOLLATE\s+(\w+)/i.exec(sql)?.[1] || null;
  const sha256 = createHash('sha256').update(sql, 'utf8').digest('hex');
  const schema = { schemaVersion: 1, source: { file: sourceName, sha256, serverVersion: version, database: db, charset, collation },
    tables: [], views: [], triggers: [], procedures: [], functions: [], events: [],
    limitations: [], security: { definersPresent: /\bDEFINER\s*=/i.test(sql), definerValuesIncluded: false, recordsIncluded: false },
    rowCount: { basis: 'Tuplas VALUES declaradas en INSERT de nivel superior; no se ejecutó el respaldo.', complete: true, byTable: {} } };
  const temporary = new Map(), final = new Map();
  for (const entry of statements(sql)) {
    const stmt = cleanStatement(entry.text);
    if (!stmt) continue;
    if (/^CREATE\s+TABLE\b/i.test(stmt)) { schema.tables.push(parseTable(stmt, entry.line)); continue; }
    if (/^INSERT\b/i.test(stmt)) {
      const insert = parseInsert(stmt);
      if (!insert) { schema.rowCount.complete = false; schema.limitations.push(`INSERT no interpretado cerca de línea ${entry.line}`); continue; }
      schema.rowCount.byTable[insert.table] = (schema.rowCount.byTable[insert.table] || 0) + (insert.count || 0);
      if (!insert.complete) { schema.rowCount.complete = false; schema.limitations.push(`${insert.table}: ${insert.reason}`); }
      continue;
    }
    if (/^(?:REPLACE|LOAD\s+DATA|UPDATE|DELETE)\b/i.test(stmt)) {
      schema.rowCount.complete = false; schema.limitations.push(`Sentencia modificadora no contabilizada cerca de línea ${entry.line}`); continue;
    }
    if (/^ALTER\s+TABLE\b/i.test(stmt) && !/^ALTER\s+TABLE\s+`[^`]+`\s+(?:DISABLE|ENABLE)\s+KEYS\s*$/i.test(stmt)) {
      schema.limitations.push(`ALTER TABLE no interpretado cerca de línea ${entry.line}`); continue;
    }
    if (/^TRUNCATE\b/i.test(stmt)) { schema.rowCount.complete = false; schema.limitations.push(`TRUNCATE no interpretado cerca de línea ${entry.line}`); continue; }
    const clean = removeDefiner(stmt);
    if (/^CREATE\s+DATABASE\b/i.test(clean)) continue;
    const trig = new RegExp('^CREATE\\s+TRIGGER\\s+' + idPattern + '\\s+(BEFORE|AFTER)\\s+(INSERT|UPDATE|DELETE)\\s+ON\\s+' + idPattern, 'i').exec(clean);
    if (trig) { schema.triggers.push({ name: unquoteId(trig[1]), timing: trig[2].toUpperCase(), event: trig[3].toUpperCase(), table: unquoteId(trig[4]), references: extractReferences(clean), actions: extractActions(clean), columnUses: extractColumnUses(clean), containsSignal: /\bSIGNAL\s+SQLSTATE\b/i.test(clean), line: entry.line }); continue; }
    const routine = new RegExp('^CREATE\\s+(PROCEDURE|FUNCTION)\\s+' + idPattern + '\\s*\\(', 'i').exec(clean);
    if (routine) {
      const open = clean.indexOf('(', routine[0].length - 1), close = matchingParen(clean, open);
      const params = splitTop(clean.slice(open + 1, close)).map(x => x.trim());
      const obj = { name: unquoteId(routine[2]), parameters: params, references: extractReferences(clean.slice(close + 1)), actions: extractActions(clean.slice(close + 1)), columnUses: extractColumnUses(clean.slice(close + 1)),
        security: /\bSQL\s+SECURITY\s+(DEFINER|INVOKER)/i.exec(clean)?.[1].toUpperCase() || 'NO DECLARADO',
        containsTransaction: /\b(?:START\s+TRANSACTION|COMMIT|ROLLBACK)\b/i.test(clean), line: entry.line };
      (routine[1].toUpperCase() === 'FUNCTION' ? schema.functions : schema.procedures).push(obj); continue;
    }
    const ev = new RegExp('^CREATE\\s+(?:OR\\s+REPLACE\\s+)?EVENT\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?' + idPattern, 'i').exec(clean);
    if (ev) { schema.events.push({ name: unquoteId(ev[1]), schedule: /\bON\s+SCHEDULE\s+([\s\S]*?)(?=\s+ON\s+COMPLETION|\s+ENABLE|\s+DISABLE|\s+COMMENT|\s+DO\b)/i.exec(clean)?.[1].trim() || 'No interpretado', references: extractReferences(clean), line: entry.line }); continue; }
    const view = new RegExp('^CREATE\\s+(?:ALGORITHM\\s*=\\s*\\w+\\s+)?(?:SQL\\s+SECURITY\\s+(?:DEFINER|INVOKER)\\s+)?VIEW\\s+' + idPattern + '\\s+AS\\s+', 'i').exec(clean);
    if (view) {
      const name = unquoteId(view[1]), body = clean.slice(view[0].length);
      const placeholder = /^SELECT\s+1\s+AS\s+`/i.test(body);
      const obj = { name, references: extractReferences(body), security: /\bSQL\s+SECURITY\s+(DEFINER|INVOKER)/i.exec(clean)?.[1].toUpperCase() || 'NO DECLARADO', line: entry.line };
      if (placeholder) temporary.set(name, [...body.matchAll(/\b1\s+AS\s+`([^`]+)`/gi)].map(m => m[1])); else final.set(name, obj);
      continue;
    }
    if (/^CREATE\b/i.test(clean)) schema.limitations.push(`CREATE no interpretado cerca de línea ${entry.line}: ${clean.slice(0, 60).replace(/\s+/g, ' ')}`);
  }
  schema.views = [...final.values()];
  for (const [name, columns] of temporary) {
    if (!final.has(name)) schema.limitations.push(`Vista temporal ${name} sin definición final reconocida`);
    else final.get(name).columns = columns;
  }
  const byName = new Map(schema.tables.map(t => [t.name, t]));
  if (byName.size !== schema.tables.length) throw new Error('Existen nombres de tablas duplicados');
  for (const table of schema.tables) {
    table.rows = schema.rowCount.byTable[table.name] || 0;
    for (const fk of table.foreignKeys) {
      if (fk.columns.length !== fk.references.length || !fk.columns.length) throw new Error(`FK compuesta inválida: ${table.name}.${fk.name}`);
      const target = byName.get(fk.target);
      if (!target) { schema.limitations.push(`Referencia externa o ausente: ${table.name}.${fk.name} → ${fk.target}`); continue; }
      for (const col of fk.columns) if (!table.columns.some(c => c.name === col)) throw new Error(`FK ${fk.name}: columna de origen ausente`);
      for (const col of fk.references) if (!target.columns.some(c => c.name === col)) throw new Error(`FK ${fk.name}: columna de destino ausente`);
      fk.optional = fk.columns.some(name => table.columns.find(c => c.name === name).nullable);
      fk.unique = table.indexes.some(index => ['primary', 'unique'].includes(index.kind) && index.columns.length > 0 && index.columns.every(c => fk.columns.includes(c)));
      fk.targetUnique = target.indexes.some(index => ['primary', 'unique'].includes(index.kind) && index.columns.length > 0 && index.columns.every(c => fk.references.includes(c)));
    }
    for (const c of table.columns) {
      c.indexes = table.indexes.filter(i => i.columns.includes(c.name)).map(i => ({ name: i.name, kind: i.kind, columns: i.columns }));
      c.foreignKeys = table.foreignKeys.filter(f => f.columns.includes(c.name)).map(f => f.name);
    }
    for (const issue of table.unsupported) schema.limitations.push(`${table.name}: ${issue}`);
    delete table.unsupported;
  }
  for (const tableName of Object.keys(schema.rowCount.byTable)) if (!byName.has(tableName)) { schema.rowCount.complete = false; schema.limitations.push(`Datos para tabla no declarada: ${tableName}`); }
  for(const routine of [...schema.procedures,...schema.functions,...schema.triggers]) {
    routine.warnings=[];
    for(const use of routine.columnUses) {
      const table=byName.get(use.table);
      if(!table)continue;
      for(const column of use.columns)if(!table.columns.some(c=>c.name.toLowerCase()===column.toLowerCase()))routine.warnings.push(`${use.operation}: ${table.name}.${column} no aparece en la definición de la tabla del respaldo.`);
    }
  }
  schema.rowCount.total = schema.tables.reduce((n, t) => n + t.rows, 0);
  schema.metrics = { tables: schema.tables.length, columns: schema.tables.reduce((n,t)=>n+t.columns.length,0),
    foreignKeys: schema.tables.reduce((n,t)=>n+t.foreignKeys.length,0), views: schema.views.length,
    triggers: schema.triggers.length, procedures: schema.procedures.length, functions: schema.functions.length, events: schema.events.length,
    primaryIndexes: schema.tables.reduce((n,t)=>n+t.indexes.filter(i=>i.kind==='primary').length,0),
    uniqueIndexes: schema.tables.reduce((n,t)=>n+t.indexes.filter(i=>i.kind==='unique').length,0),
    otherIndexes: schema.tables.reduce((n,t)=>n+t.indexes.filter(i=>i.kind==='index').length,0),
    rows: schema.rowCount.total, tablesWithRows: schema.tables.filter(t=>t.rows>0).length };
  schema.metrics.physicalIndexes = schema.metrics.primaryIndexes + schema.metrics.uniqueIndexes + schema.metrics.otherIndexes;
  return schema;
}
