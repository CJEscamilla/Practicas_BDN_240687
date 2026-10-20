"""Genera un HTML autónomo a partir del respaldo y los scripts del proyecto."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]


def parse_table(name, body, ddl, source):
    columns = []
    for line in body.splitlines():
        match = re.match(r"\s*`?(\w+)`?\s+(int(?:\s+unsigned)?|varchar\(\d+\)|char\(\d+\)|decimal\(\d+,\d+\)|enum\([^\n]+?\)|tinyint|bit\(\d+\)|datetime|text|json)(.*)", line, re.I)
        if not match:
            continue
        col, typ, suffix = match.groups()
        columns.append({'name': col, 'type': typ.upper(), 'required': 'NOT NULL' in suffix.upper(), 'auto': 'AUTO_INCREMENT' in suffix.upper(), 'generated': 'GENERATED' in suffix.upper()})
    def names(raw):
        return [s.strip().strip('`') for s in raw.split(',')]
    pk = re.search(r'PRIMARY KEY\s*\(([^)]+)\)', body)
    primary = names(pk[1]) if pk else []
    foreign = [{'columns': names(m[1]), 'table': m[2], 'references': names(m[3])} for m in re.finditer(r'FOREIGN KEY\s*\(([^)]+)\) REFERENCES\s+`?(\w+)`?\s*\(([^)]+)\)', body)]
    unique = [names(m[1]) for m in re.finditer(r'UNIQUE KEY\s+`?\w+`?\s*\(([^)]+)\)', body)]
    return dict(name=name, columns=columns, primary=primary, foreign=foreign, unique=unique, ddl=ddl, source=source)


def build():
    dump_path = ROOT / 'backups/respaldo10_14.sql'
    dump = dump_path.read_text(encoding='utf-8')
    tables = {}
    for match in re.finditer(r'CREATE TABLE `(\w+)` \((.*?)\) ENGINE=[^;]+;', dump, re.S):
        tables[match[1]] = parse_table(match[1], match[2], match[0], 'Respaldo 14/10/2026')
    script = (ROOT / 'scripts/create_ecommerce_tables.sql').read_text(encoding='utf-8')
    for match in re.finditer(r'CREATE TABLE IF NOT EXISTS (\w+) \((.*?)\) ENGINE=[^;]+;', script, re.S):
        if match[1] not in tables:
            tables[match[1]] = parse_table(match[1], match[2], match[0], 'Script de ampliación')
    for table in tables.values():
        table['rows'] = None
        if table['source'].startswith('Respaldo'):
            table['rows'] = sum(len(re.findall(r'(?:VALUES |\),)\(\d+,', line)) for line in dump.splitlines() if line.startswith('INSERT INTO `' + table['name'] + '`'))
        trigger_sources = dump + '\n' + (ROOT / 'scripts/create_ecommerce_audit_triggers.sql').read_text(encoding='utf-8')
        table['triggers'] = sorted(set(re.findall(r'(?:TRIGGER\s+`?)(\w+)`?\s+(?:AFTER|BEFORE)\s+(?:INSERT|UPDATE|DELETE)\s+ON\s+`?' + re.escape(table['name']) + r'`?\b', trigger_sources, re.I)))
        table['view'] = 'vw_trazabilidad_' + table['name'] if table['name'] not in ('tb_users', 'tb_products', 'tb_logs') else {'tb_users': 'vw_trazabilidad_usuarios_creados', 'tb_products': 'vw_trazabilidad_productos', 'tb_logs': None}[table['name']]
    model = {'database': 'db_test', 'owner': '240687', 'tables': list(tables.values()), 'note': 'Modelo documental: respaldo del 14/10/2026 + scripts locales. No conectado a MySQL.'}
    assert len(tables) == 16, f'Se esperaban 16 tablas; encontradas {len(tables)}'
    for table in tables.values():
        assert table['columns'], table['name']
        cols = {c['name'] for c in table['columns']}
        assert set(table['primary']) <= cols
        for fk in table['foreign']:
            assert set(fk['columns']) <= cols
            assert fk['table'] in tables
            assert set(fk['references']) <= {c['name'] for c in tables[fk['table']]['columns']}
    template = (ROOT / 'scripts/eer_explorer_template.html').read_text(encoding='utf-8')
    payload = json.dumps(model, ensure_ascii=False).replace('<', '\\u003c')
    output = ROOT / 'explorador-eer.html'
    output.write_text(template.replace('__MODEL_DATA__', payload), encoding='utf-8')
    print(f'{output.name}: {len(tables)} tablas, {sum(len(t["foreign"]) for t in tables.values())} relaciones FK. Sin datos personales ni credenciales.')


if __name__ == '__main__':
    build()
