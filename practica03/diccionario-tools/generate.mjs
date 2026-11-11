import { readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseDump, statements, cleanStatement, removeDefiner } from './sql-parser.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const input = resolve(process.argv[2] || resolve(here, '../backups/dicionario.sql'));
const output = resolve(process.argv[3] || resolve(here, '../diccionario-publico/schema.json'));
const descriptions = {
  tb_buyer_orders: 'Pedidos realizados por compradores, con importes y referencias de compra.',
  tb_carts: 'Carritos asociados a usuarios y su estado.',
  tb_logs: 'Bitácora de operaciones registradas en el modelo.',
  tb_order_cancellations: 'Solicitudes y seguimiento de cancelaciones de pedidos.',
  tb_payment_methods: 'Métodos de pago disponibles.',
  tb_payment_transaction: 'Operaciones de pago o reembolso y respuestas del proveedor.',
  tb_payments: 'Pagos asociados a pedidos.',
  tb_people: 'Datos de personas vinculadas con usuarios.',
  tb_products: 'Catálogo de productos, precio y existencias.',
  tb_refunds: 'Reembolsos asociados a pagos, cancelaciones o devoluciones.',
  tb_returns: 'Solicitudes y seguimiento de devoluciones de pedidos.',
  tb_shipments: 'Envíos, dirección de entrega y seguimiento.',
  tb_user_addresses: 'Direcciones asociadas a usuarios.',
  tb_users: 'Cuentas de usuario del sistema.',
  tbc_carts_items: 'Catálogo de estados o tipos de artículos del carrito.',
  tbc_categories: 'Categorías del catálogo de comercio electrónico.',
  tbc_order_items: 'Catálogo de estados o tipos de artículos de pedido.',
  tbc_payment_methods_types: 'Catálogo de tipos de métodos de pago.',
  tbd_cancellation_items: 'Artículos asociados a una cancelación.',
  tbd_carts_items: 'Productos y cantidades de cada carrito.',
  tbd_order_itemes: 'Detalle de productos e importes de un pedido.',
  tbd_products_categories: 'Asociaciones entre productos y categorías.',
  tbd_products_users_providers: 'Asociaciones entre productos y usuarios proveedores.',
  tbd_return_items: 'Artículos asociados a una devolución.',
  tbd_user_payment_methods: 'Métodos de pago vinculados a usuarios.',
  tbd_users_wishilst_products: 'Asociaciones entre usuarios y productos de su lista de deseos.'
};
const domains = {
  Identidad: ['tb_users', 'tb_people', 'tb_user_addresses'],
  Catálogo: ['tb_products', 'tbc_categories', 'tbd_products_categories', 'tbd_products_users_providers', 'tbd_users_wishilst_products'],
  Compra: ['tb_carts', 'tbc_carts_items', 'tbd_carts_items', 'tb_buyer_orders', 'tbc_order_items', 'tbd_order_itemes'],
  Pagos: ['tb_payment_methods', 'tbc_payment_methods_types', 'tbd_user_payment_methods', 'tb_payments', 'tb_payment_transaction'],
  Posventa: ['tb_order_cancellations', 'tbd_cancellation_items', 'tb_returns', 'tbd_return_items', 'tb_refunds', 'tb_shipments'],
  Auditoría: ['tb_logs']
};
const terms = {id:'identificador',user:'usuario',buyer:'comprador',order:'pedido',cart:'carrito',product:'producto',category:'categoría',status:'estado',name:'nombre',description:'descripción',code:'código',date:'fecha',creation:'creación',last:'última',update:'actualización',payment:'pago',method:'método',type:'tipo',amount:'importe',currency:'moneda',price:'precio',quantity:'cantidad',stock:'existencias',shipping:'envío',address:'dirección',recipient:'destinatario',provider:'proveedor',reference:'referencia',transaction:'transacción',return:'devolución',refund:'reembolso',cancellation:'cancelación',reason:'motivo',detail:'detalle',requested:'solicitado',processed:'procesado',at:'fecha y hora',tax:'impuesto',discount:'descuento',total:'total',grand:'final',snapshot:'copia al momento de la operación',email:'correo electrónico',password:'contraseña',nickname:'alias',phone:'teléfono',country:'país',city:'ciudad',state:'estado o región',postal:'postal',number:'número',created:'creado',operation:'operación',table:'tabla',sku:'SKU',item:'artículo',items:'artículos',current:'actual',people:'personas',given:'de pila',family:'familiares',birth:'nacimiento',gender:'género',label:'etiqueta',street:'calle',interior:'interior',exterior:'exterior',neighborhood:'colonia',delivery:'entrega',instructions:'instrucciones',carrier:'transportista',tracking:'seguimiento',url:'URL',cost:'costo',response:'respuesta',request:'solicitud',message:'mensaje',scope:'alcance',internal:'internas',notes:'notas',quantity:'cantidad',condition:'condición',disposition:'disposición',approved:'aprobado',display:'visible',four:'cuatro',active:'activo',login:'inicio de sesión',sup:'superior'};
const commonMeanings={
  id:'Número que identifica la fila.', user_id:'Identificador del usuario relacionado.', product_id:'Identificador del producto relacionado.', category_id:'Identificador de la categoría relacionada.', order_id:'Identificador del pedido relacionado.', cart_id:'Identificador del carrito relacionado.',
  sku:'Código usado para identificar un producto.', name:'Nombre asignado al elemento.', description:'Texto descriptivo del elemento.', status:'Estado del elemento; su significado específico depende de la aplicación.',
  creation_date:'Fecha y hora de creación de la fila.', last_update:'Fecha y hora de la última actualización.', last_login:'Fecha y hora del último inicio de sesión.',
  current_price:'Precio actual del producto.', current_stock:'Cantidad disponible del producto.', quantity:'Cantidad de unidades asociadas.', currency:'Código de moneda del importe.', amount:'Importe de la operación.',
  email:'Dirección de correo de la cuenta.', nickname:'Nombre o alias visible de la cuenta.', password:'Campo asociado a la contraseña de la cuenta; su formato debe verificarse fuera del diccionario.',
  table_name:'Nombre de la tabla a la que se refiere la operación registrada.', operation:'Tipo de operación registrada.', db_users:'Usuario de base de datos asociado al registro de auditoría.', operation_date:'Fecha y hora de la operación registrada.', operation_status:'Estado de la operación registrada.',
  grand_total:'Importe final calculado a partir de otros importes del pedido.', subtotal:'Importe antes de ajustes como descuentos, impuestos y envío.', discount_total:'Importe total de descuentos.', tax_total:'Importe total de impuestos.', shipping_total:'Importe total de envío.',
  order_number:'Número que identifica el pedido en el negocio.', shipping_address_snapshot:'Copia de los datos de dirección guardados al realizar la compra.',
  city:'Ciudad de la dirección.', postal_code:'Código postal de la dirección.', country_code:'Código del país.', phone:'Número telefónico asociado.',
  sup_id_category:'Identificador que sugiere una categoría superior; no se presume una FK sin declaración.'
};
function fieldMeaning(name) {
  if(commonMeanings[name.toLowerCase()])return `Interpretación: ${commonMeanings[name.toLowerCase()]}`;
  const words = name.replace(/([a-z])([A-Z])/g, '$1_$2').split('_').map(w => terms[w.toLowerCase()] || w);
  return `Interpretación del nombre: ${words.join(' ')}.`;
}
function classify(c) {
  const t = c.type.toLowerCase(), id = /(?:^id$|_id$|^id_|sku|email|phone|code|number|reference|key|currency|postal)/i.test(c.name);
  let nature = 'No determinada', scale = 'No determinada';
  if (t.startsWith('json')) nature = 'Estructurada';
  else if (/^(?:date|datetime|timestamp|time|year)/.test(t)) { nature = 'Temporal'; scale = 'Intervalo (interpretación)'; }
  else if (id || /status|state|gender|condition|scope/i.test(c.name) || /^(?:enum|set|char|varchar|text|bit|binary|varbinary)/.test(t)) { nature = 'Cualitativa'; scale = 'Nominal (interpretación)'; }
  else if (/^(?:int|tinyint|smallint|mediumint|bigint|decimal|numeric|float|double|real)/.test(t)) { nature = 'Cuantitativa'; scale = 'Razón posible; depende del uso'; }
  return {
    explanation: c.comment ? `Comentario del SQL: ${c.comment}` : fieldMeaning(c.name),
    evidence: c.comment ? 'Comentario declarado; clasificación interpretativa.' : 'Interpretación; el significado no está declarado.',
    quantity: t.startsWith('set(') ? 'Multivalorado (SET)' : t.startsWith('json') ? 'Puede contener múltiples valores (JSON)' : 'Monovalorado por celda',
    composition: t.startsWith('json') ? 'Compuesto potencial (JSON)' : 'Simple en el modelo físico; interpretación',
    nature, scale,
    domain: `Tipo ${c.type}; sujeto a las claves y restricciones declaradas en la tabla.`,
    origin: c.generated ? (c.generatedStored ? 'Derivado y almacenado' : 'Derivado') : 'Almacenado',
    omittable: c.generated ? 'Sí: columna generada; si se especifica, solo DEFAULT.' : c.autoIncrement ? 'Sí: AUTO_INCREMENT.' : c.defaultDeclared ? 'Sí: se aplica el valor predeterminado declarado.' : c.nullable ? 'Sí: recibe NULL implícito.' : 'No en modo estricto, salvo intervención de un trigger.',
  };
}

const sql = await readFile(input, 'utf8');
const model = parseDump(sql, { sourceName: basename(input) });
for (const t of model.tables) {
  t.domain = Object.entries(domains).find(([,names]) => names.includes(t.name))?.[0] || 'Otros';
  t.description = descriptions[t.name] || `Propósito no documentado; revisar ${t.name}.`;
  t.descriptionEvidence = 'Interpretación basada en nombres y relaciones; no es una regla declarada.';
  for (const c of t.columns) Object.assign(c, classify(c));
}
model.domainNames = [...new Set(model.tables.map(t => t.domain))];
model.notes = [
 'Los conteos son tuplas INSERT VALUES de nivel superior incluidas en el respaldo, no una consulta a la base activa.',
 'Las relaciones visualizadas son exclusivamente claves foráneas declaradas. Un par de claves compuestas es una sola relación.',
 'Cada índice físico se cuenta una vez: PRIMARY, UNIQUE u otro índice; los totales por tipo suman el total físico. Las restricciones PK y UNIQUE se describen sin sumarlas de nuevo.',
 'Los dominios de negocio, descripciones semánticas y clasificaciones de campos son interpretaciones y requieren confirmación.',
 'Las vistas temporales del volcado se excluyen y solo se conservan las definiciones finales. Los tipos y nulabilidad de columnas de vista no se infieren del SELECT de prueba.',
 'Las cuentas DEFINER y las filas no se incluyen en este modelo público. Los cuerpos SQL completos permanecen en el respaldo de origen.'
];
if (model.limitations.length || !model.rowCount.complete) throw new Error('Extracción incompleta: ' + model.limitations.join('; '));
await writeFile(output, JSON.stringify(model, null, 2) + '\n', 'utf8');
const csvHeaders=['objeto','clase_objeto','campo','tipo_sql','admite_null','puede_omitirse','predeterminado','cantidad','composicion','naturaleza','escala','dominio','origen','claves_restricciones','explicacion','evidencia'];
const csvRows=[];
for(const t of model.tables)for(const c of t.columns)csvRows.push([t.name,'Tabla',c.name,c.type,c.nullable?'Sí':'No',c.omittable,c.defaultDeclared?c.default:'No declarado',c.quantity,c.composition,c.nature,c.scale,c.domain,c.origin,c.indexes.map(i=>`${i.kind}:${i.name}(${i.columns.join('+')})`).concat(c.foreignKeys.map(f=>`FK:${f}`)).join(' | '),c.explanation,c.evidence]);
for(const v of model.views)for(const c of v.columns||[])csvRows.push([v.name,'Vista',c,'No comprobado sin motor','No comprobado','No aplica a SELECT','No comprobado','No determinada','No determinada','No determinada','No determinada','Resultado de la expresión de la vista','Proyectado','No declaradas en la vista',`Columna proyectada ${c}; significado por confirmar.`,'Alias comprobado; tipo y nulabilidad no inferidos de la vista temporal.']);
const csvCell=x=>'"'+String(x??'').replace(/"/g,'""')+'"';
await writeFile(resolve(dirname(output),'campos_clasificados.csv'),'\ufeff'+[csvHeaders,...csvRows].map(row=>row.map(csvCell).join(',')).join('\r\n')+'\r\n','utf8');
const definitions=[];
for(const part of statements(sql)){
  let stmt=removeDefiner(cleanStatement(part.text));
  if(!/^CREATE\b/i.test(stmt)||/^CREATE\s+DATABASE\b/i.test(stmt))continue;
  if(/^CREATE\s+VIEW\s+`[^`]+`\s+AS\s+SELECT\s+1\s+AS\s+`/i.test(stmt))continue;
  if(!/^CREATE\s+TABLE\b/i.test(stmt)&&!/\b(?:VIEW|TRIGGER|PROCEDURE|FUNCTION|EVENT)\s+`/i.test(stmt))continue;
  if(/IDENTIFIED\s+(?:BY|WITH)|(?:PASSWORD|TOKEN|SECRET)\s*=\s*['"]/i.test(stmt)||/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i.test(stmt)) throw new Error('Definición contiene posible información sensible; revisar antes de exportar.');
  definitions.push(stmt);
}
const expectedDefinitions=model.metrics.tables+model.metrics.views+model.metrics.triggers+model.metrics.procedures+model.metrics.functions+model.metrics.events;
if(definitions.length!==expectedDefinitions)throw new Error(`Anexo incompleto: ${definitions.length} de ${expectedDefinitions} objetos`);
const annex=['-- ANEXO DE LECTURA: no usar para restaurar la base.','-- Definiciones del respaldo; se omiten filas, CREATE DATABASE y cuentas DEFINER.','-- SQL SECURITY DEFINER indica un modo de ejecución, no una cuenta.',`-- Fuente: ${model.source.file}; SHA-256: ${model.source.sha256}`,'DELIMITER ;;',...definitions.map(s=>s+';;'),'DELIMITER ;',''].join('\n');
await writeFile(resolve(dirname(output),'anexo_definiciones.sql'),annex,'utf8');
console.log(JSON.stringify({ output, sha256: model.source.sha256, metrics: model.metrics, limitations: model.limitations }, null, 2));
