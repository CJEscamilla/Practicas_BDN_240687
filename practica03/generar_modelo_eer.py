"""Regenera el visor sin dependencias: python practica03/generar_modelo_eer.py."""
from pathlib import Path
import re, json, hashlib

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
preferred = HERE / 'backups/respaldo10_20.sql'
source = preferred if preferred.exists() else max((HERE / 'backups').glob('*.sql'), key=lambda p: p.stat().st_mtime)
sql = source.read_text(encoding='utf-8-sig')

def split_sql(text, delimiter=','):
    """Separa solo fuera de cadenas, comentarios y paréntesis anidados."""
    start = depth = i = 0
    quote = None
    while i < len(text):
        c = text[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                if i + 1 < len(text) and text[i + 1] == quote:
                    i += 2
                    continue
                quote = None
        elif c in "'\"`":
            quote = c
        elif text.startswith('/*', i):
            end = text.find('*/', i + 2)
            i = len(text) if end < 0 else end + 2
            continue
        elif c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        elif c == delimiter and depth == 0:
            yield text[start:i].strip()
            start = i + 1
        i += 1
    if text[start:].strip():
        yield text[start:].strip()

tables, relations = [], []
for m in re.finditer(r'CREATE TABLE `([^`]+)`\s*\((.*?)\)\s*(ENGINE=[^;]+);', sql, re.S | re.I):
    name, body, options = m.groups()
    table = dict(name=name, columns=[], indexes=[], checks=[], rows=0, engine=re.search(r'ENGINE=(\w+)', options)[1], ddl=m[0], line=sql.count('\n', 0, m.start()) + 1)
    for part in split_sql(body):
        if part.startswith('`'):
            cm = re.match(r'`([^`]+)`\s+(.+)', part, re.S)
            cn, rest = cm.groups()
            # SQL types may contain nested parentheses, spaces and quoted enum values.
            tm = re.match(r'\w+', rest)
            end = tm.end()
            if end < len(rest) and rest[end] == '(':
                depth, quote, i = 0, None, end
                while i < len(rest):
                    c = rest[i]
                    if quote:
                        if c == '\\': i += 2; continue
                        if c == quote: quote = None
                    elif c in "'\"": quote = c
                    elif c == '(': depth += 1
                    elif c == ')':
                        depth -= 1
                        if depth == 0: end = i + 1; break
                    i += 1
            modifier = re.match(r'(?:\s+(?:unsigned|zerofill))+', rest[end:], re.I)
            if modifier: end += modifier.end()
            constraints = rest[end:]
            dm = re.search(r"\bDEFAULT\s+((?:[bBxX])?'(?:\\.|''|[^'])*'|[^\s,]+)", constraints, re.I)
            comment = re.search(r"\bCOMMENT\s+'((?:\\.|''|[^'])*)'", constraints, re.I)
            table['columns'].append(dict(name=cn, type=rest[:end], nn=bool(re.search(r'\bNOT NULL\b', constraints, re.I)), ai=bool(re.search(r'\bAUTO_INCREMENT\b', constraints, re.I)), default=dm[1] if dm else None, comment=comment[1] if comment else '', definition=part, pk=False, uq=False, fk=False))
        elif re.match(r'(PRIMARY KEY|UNIQUE KEY|KEY|FULLTEXT KEY|SPATIAL KEY)', part):
            kind = 'PK' if part.startswith('PRIMARY') else 'UQ' if part.startswith('UNIQUE') else 'INDEX'
            im = re.search(r'\((.+)\)', part)
            cols = re.findall(r'`([^`]+)`', im[1])
            names = re.findall(r'`([^`]+)`', part[:im.start()])
            table['indexes'].append(dict(name=names[0] if names else 'PRIMARY', kind=kind, columns=cols, definition=part))
        elif 'FOREIGN KEY' in part:
            fm = re.search(r'CONSTRAINT `([^`]+)` FOREIGN KEY\s*\((.*?)\) REFERENCES `([^`]+)`\s*\((.*?)\)(.*)', part, re.S)
            assert fm, part
            fk, cols, target, refs, actions = fm.groups()
            relations.append(dict(id=fk, source=name, columns=re.findall(r'`([^`]+)`', cols), target=target, references=re.findall(r'`([^`]+)`', refs), actions=actions.strip(), definition=part))
        elif 'CHECK' in part:
            table['checks'].append(part)
    for idx in table['indexes']:
        for col in table['columns']:
            if col['name'] in idx['columns'] and idx['kind'] in ('PK', 'UQ'):
                col['pk' if idx['kind'] == 'PK' else 'uq'] = True
                if idx['kind'] == 'PK': col['nn'] = True
    tables.append(table)

by_name = {t['name']: t for t in tables}
# Dump INSERTs can span lines and contain commas, escaped quotes and parentheses in text.
for statement in split_sql(sql, ';'):
    im = re.search(r'(?:^|\n)INSERT INTO `([^`]+)`\s*(?:\([^;]*?\))?\s+VALUES\s*(.*)', statement, re.S | re.I)
    if im and im[1] in by_name:
        tuples = list(split_sql(im[2]))
        assert all(t.startswith('(') and t.endswith(')') for t in tuples)
        by_name[im[1]]['rows'] += len(tuples)
for r in relations:
    assert len(r['columns']) == len(r['references'])
    for c, ref in zip(r['columns'], r['references']):
        col = next(cn for cn in by_name[r['source']]['columns'] if cn['name'] == c)
        assert any(cn['name'] == ref for cn in by_name[r['target']]['columns'])
        col['fk'] = True
        col.setdefault('references', []).append(r['target'] + '.' + ref)
    r['optional'] = any(c['name'] in r['columns'] and not c['nn'] for c in by_name[r['source']]['columns'])
    r['unique'] = any(i['kind'] in ('PK','UQ') and set(i['columns']).issubset(r['columns']) for i in by_name[r['source']]['indexes'])

data = dict(database='db_test', source=source.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(source.read_bytes()).hexdigest(), tables=tables, relations=relations)
template = (HERE / 'modelo-eer.template.html').read_text(encoding='utf-8')
(HERE / 'modelo-eer.html').write_text(template.replace('__SCHEMA_DATA__', json.dumps(data, ensure_ascii=False).replace('<', '\\u003c')), encoding='utf-8')
# Native Archify model: a reproducible schema companion with repository evidence.
out = ROOT / '.archify/erd-db-test'
out.mkdir(parents=True, exist_ok=True)
domains = [('Identidad', ['tb_users','tb_user_addresses','tbd_user_payment_methods','tbc_payment_methods_types']), ('Catálogo', ['tb_products','tbc_categories','tbd_products_categories','tbd_products_users_providers','tbd_users_wishilst_products']), ('Compra', ['tb_carts','tbd_carts_items','tbc_carts_items','tb_buyer_orders','tbd_order_itemes','tbc_order_items']), ('Auditoría', ['tb_logs'])]
entities=[]
for col, (tag, names) in enumerate(domains):
    for row, name in enumerate(names):
        t=by_name[name]
        attrs=[]
        for c in t['columns']:
            a=dict(name=c['name'], type=c['type'])
            keys=[k for k, flag in [('pk',c['pk']),('fk',c['fk']),('uk',c['uq'])] if flag]
            if keys: a['key']=keys
            if c['fk']: a['references']=c['references'][0]
            attrs.append(a)
        entities.append(dict(id=name,label=name,tag=tag,row=row,col=col,width=600 if name=='tb_buyer_orders' else 380,attributes=attrs,sources=[dict(path=data['source'],line=t['line'],end_line=t['line']+t['ddl'].count('\n'))]))
candidate=dict(schema_version=1,diagram_type='erd',meta=dict(title='DB_TEST · Modelo físico completo',locale='es',output='.archify/erd-db-test/archify.html',quality_profile='standard',repository=dict(url='https://github.com/CJEscamilla/Practicas_BDN_240687.git',revision='5d27fb48acfa2016b06b5ae510289c6ea23bbc9e')),layout=dict(mode='grid',gapX=110,gapY=60,entityW=360),entities=entities,relationships=[dict(id=r['id'],**{'from':r['source'],'to':r['target']},fromCardinality='one' if r['unique'] else 'many',toCardinality='one',fromOptional=True,toOptional=r['optional']) for r in relations])
(out/'candidate.json').write_text(json.dumps(candidate,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(dict(tables=len(tables),columns=sum(len(t['columns']) for t in tables),relations=len(relations),column_pairs=sum(len(r['columns']) for r in relations),rows=sum(t['rows'] for t in tables),counts={t['name']:t['rows'] for t in tables}),indent=2))
