import pathlib,re,json,csv,html,datetime,hashlib
root=pathlib.Path.cwd(); src=root/'practica03/backups/respaldo10_28.1.sql'; raw=src.read_text(encoding='utf-8')
out=root/'.archify/diccionario-db-test-20261104'; out.mkdir(parents=True,exist_ok=True)
tables=[]
for m in re.finditer(r'CREATE TABLE `([^`]+)` \(([\s\S]*?)\) ENGINE=([^;]+);',raw):
 name,body,opts=m.groups(); rows=body.strip().splitlines(); cols=[]; constraints=[]
 for line in rows:
  line=line.strip().rstrip(','); c=re.match(r'`([^`]+)`\s+(.+)',line)
  if c: cols.append((c.group(1),c.group(2)))
  else: constraints.append(line)
 tables.append(dict(name=name,columns=cols,constraints=constraints,sql=m.group(0),line=raw.count('\n',0,m.start())+1))
views=[]
for m in re.finditer(r'/\*!50001 VIEW `([^`]+)` AS ([\s\S]*?) \*/;',raw):
 name,body=m.groups(); temp=re.search(r'CREATE VIEW `'+re.escape(name)+r'` AS SELECT\s+([\s\S]*?)\*/;',raw)
 fields=re.findall(r'1 AS `([^`]+)`',temp.group(1)) if temp else []
 views.append(dict(name=name,body=body,fields=fields,line=raw.count('\n',0,m.start())+1))
triggers=[]
for m in re.finditer(r'/\*!50003 CREATE\*/\s*/\*!50017 DEFINER=.*?\*/\s*/\*!50003 (TRIGGER `([^`]+)`[\s\S]*?)\*/;;',raw):
 triggers.append(dict(name=m.group(2),sql='CREATE '+m.group(1)+';',line=raw.count('\n',0,m.start())+1))
routines=[]
for m in re.finditer(r'CREATE DEFINER=.*? (PROCEDURE|FUNCTION) `([^`]+)`([\s\S]*?)END\s*;;',raw):
 routines.append(dict(kind=m.group(1),name=m.group(2),sql='CREATE '+m.group(1)+' `'+m.group(2)+'`'+m.group(3)+'END;',line=raw.count('\n',0,m.start())+1))
def esc(x): return html.escape(str(x),quote=True)
words={'id':'identificador','order':'pedido','buyer':'comprador','user':'usuario','cart':'carrito','shipping':'envío','address':'dirección','payment':'pago','method':'método','status':'estado','currency':'moneda','snapshot':'copia al momento de la operación','subtotal':'subtotal','discount':'descuento','total':'total','tax':'impuesto','grand':'final','creation':'creación','date':'fecha','last':'última','update':'actualización','number':'número','name':'nombre','description':'descripción','table':'tabla','operation':'operación','requested':'solicitado','reviewed':'revisado','completed':'completado','at':'en fecha y hora','reason':'motivo','code':'código','detail':'detalle','internal':'internas','notes':'notas','amount':'importe','provider':'proveedor','reference':'referencia','transaction':'transacción','type':'tipo','response':'respuesta','message':'mensaje','paid':'pagado','person':'persona','title':'título','given':'de pila','names':'nombres','family':'apellidos','birth':'nacimiento','gender':'género','phone':'teléfono','country':'país','current':'actual','price':'precio','stock':'existencias','refund':'reembolso','return':'devolución','cancellation':'cancelación','processed':'procesado','recipient':'destinatario','line':'línea','city':'ciudad','state':'estado o región','region':'región','postal':'postal','carrier':'transportista','service':'servicio','level':'nivel','tracking':'rastreo','cost':'costo','shipped':'enviado','estimated':'estimado','delivery':'entrega','delivered':'entregado','label':'etiqueta','street':'calle','exterior':'exterior','interior':'interior','neighborhood':'colonia','instructions':'instrucciones','email':'correo','nickname':'alias','password':'contraseña','login':'inicio de sesión','product':'producto','category':'categoría','sup':'superior','item':'artículo','quantity':'cantidad','sku':'SKU','unit':'unitario','acquisition':'adquisición','condition':'condición','disposition':'destino','approved':'aprobado','display':'para mostrar','four':'cuatro','scope':'alcance','request':'solicitud'}
def meaning(name):
 return ' '.join(words.get(w.lower(),w) for w in name.split('_'))
def parse_col(table,name,definition):
 typ=re.match(r'((?:enum|set)\((?:[^\']|\'[^\']*\')*?\)|[a-z]+(?:\(\d+(?:,\d+)?\))?(?: unsigned)?)',definition,re.I)
 typ=typ.group(1) if typ else definition.split()[0]
 nul='No' if re.search(r'\bNOT NULL\b',definition,re.I) else 'Sí'
 d=re.search(r'\bDEFAULT\s+(CURRENT_TIMESTAMP(?:\(\))?|NULL|b\'[^\']*\'|\'[^\']*\'|[^\s,]+)',definition,re.I)
 default=d.group(1) if d else 'No declarado'
 gen='GENERATED ALWAYS' in definition.upper(); auto='AUTO_INCREMENT' in definition.upper()
 if gen: omit='Sí: generado automáticamente; usar DEFAULT si se menciona'; origin='Derivado y almacenado' if re.search(r'\bSTORED\b',definition,re.I) else 'Derivado'
 elif auto: omit='Sí: AUTO_INCREMENT'; origin='Almacenado'
 elif d: omit='Sí: se aplica DEFAULT '+default; origin='Almacenado'
 elif nul=='Sí': omit='Sí: recibe NULL implícito'; origin='Almacenado'
 else: omit='No en modo estricto; sin valor automático declarado'; origin='Almacenado'
 low=name.lower(); t=typ.lower(); isid=(low=='id' or low.endswith('_id') or low.startswith('id_') or low in ('sku','code','email','nickname','phone','postal_code','tracking_number','order_number','last_four','provider_reference','provider_transaction_id','idempotency_key','country_code','currency'))
 if t.startswith(('json','set')): count='Multivalorado potencial' if t.startswith('json') else 'Multivalorado'; comp='Compuesto potencial' if t.startswith('json') else 'Simple'; nature='Estructurado' if t.startswith('json') else 'Cualitativa'; scale='No determinada' if t.startswith('json') else 'Nominal'
 else:
  count='Monovalorado'; comp='Simple'; nature='Cualitativa' if isid or t.startswith(('varchar','char','text','enum','bit')) or 'status' in low else ('Temporal' if t.startswith(('date','time','timestamp','year')) else 'Cuantitativa')
  scale=('No determinada' if t.startswith('enum') or low=='status' else 'Nominal') if nature=='Cualitativa' else ('Intervalo' if nature=='Temporal' else ('Razón (interpretación)' if nature=='Cuantitativa' else 'No determinada'))
 keys=[]
 for x in table['constraints']:
  if re.search(r'`'+re.escape(name)+r'`',x): keys.append(x)
 comment=re.search(r"COMMENT '([^']*)'",definition)
 desc=('Comentario SQL: '+comment.group(1)) if comment else ('Interpretación del nombre: '+meaning(name)+'; dato asociado a '+table['name']+'.')
 return dict(objeto=table['name'],clase_objeto='Tabla',campo=name,tipo_sql=typ,definicion_sql=definition,admite_null=nul,puede_omitirse=omit,predeterminado=default,cantidad=count,composicion=comp,naturaleza=nature,escala=scale,dominio='Tipo '+typ+'; véanse restricciones de la tabla',origen=origin,claves_restricciones=' | '.join(keys) or 'Sin clave o restricción explícita localizada',explicacion=desc,evidencia='Definición SQL; clasificación e interpretación sujetas a contexto',linea=table['line'])
fields=[parse_col(t,n,d) for t in tables for n,d in t['columns']]
for v in views:
 for n in v['fields']:
  fields.append(dict(objeto=v['name'],clase_objeto='Vista',campo=n,tipo_sql='No comprobado sin motor',definicion_sql='Ver SELECT de la vista en el anexo',admite_null='No comprobado',puede_omitirse='No aplica a una consulta SELECT',predeterminado='No aplica / no comprobado',cantidad='Monovalorado en la fila; roles puede contener una lista' if n=='roles' else 'Monovalorado',composicion='Compuesto potencial' if n=='roles' else 'Simple',naturaleza='No determinada',escala='No determinada',dominio='Resultado de la expresión de la vista; ver anexo',origen='Proyectado',claves_restricciones='No declaradas en la vista',explicacion='Interpretación del nombre: '+n.replace('_',' ')+'.',evidencia='Alias comprobado; tipo y nulabilidad requieren motor MySQL',linea=v['line']))
with (out/'campos_clasificados.csv').open('w',encoding='utf-8-sig',newline='') as f:
 w=csv.DictWriter(f,fieldnames=fields[0].keys()); w.writeheader(); w.writerows(fields)
ann=['-- ANEXO DE LECTURA: definiciones del respaldo; no ejecutar como restauración.','-- Se omitieron las cláusulas DEFINER que identifican cuentas. No contiene filas INSERT.','-- Fuente: practica03/backups/respaldo10_28.1.sql','-- Las líneas indicadas corresponden al respaldo original.','']
for t in tables: ann.extend(['-- TABLA '+t['name']+' | línea '+str(t['line']),t['sql'],''])
for v in views: ann.extend(['-- VISTA '+v['name']+' | línea '+str(v['line']),'CREATE VIEW `'+v['name']+'` AS '+v['body']+';',''])
for tr in triggers: ann.extend(['-- TRIGGER '+tr['name']+' | línea '+str(tr['line']),tr['sql'],''])
for r in routines: ann.extend(['-- '+r['kind']+' '+r['name']+' | línea '+str(r['line']),r['sql'],''])
(out/'anexo_definiciones.sql').write_text('\n'.join(ann),encoding='utf-8')
data=dict(tables=tables,views=views,triggers=triggers,routines=routines,fields=fields,sha256=hashlib.sha256(src.read_bytes()).hexdigest())
(out/'data.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
(out/'candidate.archify.md').write_text('''# Archivo de datos de db_test {#archivo}

El respaldo describe 26 tablas, 28 vistas, 39 triggers y 3 procedimientos. Su contenido es una fotografía del esquema, no una consulta al servidor actual.

- Las claves y restricciones proceden de las definiciones SQL del respaldo.
- Los nombres y clasificaciones de significado son interpretaciones cuando no hay comentario explícito.
- Los tipos de las columnas de vistas necesitan comprobarse en un servidor MySQL.

@answer scope="Respaldo 10/28 · definiciones, sin registros"
@meta locale=es

## ¿Cómo se relaciona la compra? {#compra}

@erd id=compra-modelo title="Relaciones declaradas de compra"
| entity usuario | tb_users |
| entity carrito | tb_carts |
| entity pedido | tb_buyer_orders |
| entity pago | tb_payments |
| usuario.ID | int | pk |
| carrito.ID | int unsigned | pk |
| carrito.user_ID | int | fk | usuario.ID |
| pedido.ID | int unsigned | pk |
| pedido.buyer_user_ID | int | fk | usuario.ID |
| pago.ID | int unsigned | pk |
| pago.order_ID | int unsigned | fk | pedido.ID |
| carrito > usuario | many:one | pertenece a |
| pedido > usuario | many:one | compra |
| pago > pedido | many:one | paga |

## ¿Qué significa que un campo se omita? {#insercion}

Un campo que admite `NULL` acepta la ausencia explícita de valor. Omitirlo significa no mencionarlo al insertar. Un valor automático o predeterminado puede permitir omitir un campo que no admite `NULL`.

## ¿Dónde están los detalles? {#detalle}

El diccionario interactivo acompaña esta vista con cada columna y sus restricciones. El anexo contiene las definiciones, sin registros ni cuentas DEFINER.
''',encoding='utf-8')
print('tablas',len(tables),'campos tabla',sum(len(t['columns']) for t in tables),'vistas',len(views),'campos vista',sum(len(v['fields']) for v in views),'triggers',len(triggers),'rutinas',len(routines),'carpeta',out)
