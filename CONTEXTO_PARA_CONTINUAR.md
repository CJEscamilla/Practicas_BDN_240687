# Contexto para continuar desde mi PC personal

Fecha de esta sesión: 20 de octubre de 2026.

## Mensaje para el próximo chat

Estoy desarrollando un proyecto académico de Base de Datos en la Nube con MySQL,
basado en un e-commerce. Lee este documento y los archivos mencionados antes de
continuar. Estuve trabajando en una computadora que no es mía y quiero retomar
desde mi PC personal. Respeta los nombres y la estructura que propone mi maestro,
explica las sugerencias y no des por ejecutados en MySQL los scripts que solo se
generaron en el repositorio. Mi BD actualmente es local. No se proporcionaron
credenciales ni una conexión autenticada al asistente.

Este documento es un resumen de continuidad de toda la conversación y del estado
del trabajo, no una transcripción literal.

## Proyecto y entorno anterior

- Repositorio: `Practicas_BDN_240687`.
- Ubicación en el equipo anterior: `C:\Optativa1\Practicas_BDN_240687`.
- Terminal: PowerShell en Windows. La ruta puede cambiar en mi computadora.
- Matrícula usada en el proyecto y explorador: `240687`.
- Asignatura: Base de Datos en la Nube, septiembre–diciembre de 2026.
- Docente indicado en README: M.T.I. Marco A. Ramírez Hernández.
- Base usada en los scripts: `db_test`.
- Motor del respaldo analizado: MySQL 8.0.36, InnoDB.
- Se detectó MySQL Shell instalado, pero NO se abrió una conexión a la BD.
- Python y Node estuvieron disponibles para generar archivos y revisar sintaxis.

## Objetivos y preferencias que expresé

1. Pedí un análisis descriptivo del proyecto y qué estoy construyendo.
2. Pregunté qué CSV se habían importado y qué roles deberían importarlos.
3. Pedí comprobar si los CSV de práctica 3 tendrían conflictos al insertarse.
4. Pedí crear tablas siguiendo los nombres del maestro, con una crítica
   constructiva; el maestro permite libertad creativa.
5. Confirmé que ejecuté los scripts de creación de tablas en mi BD local.
6. Después pedí tres triggers por tabla: INSERT, UPDATE y DELETE.
7. Pedí una vista por tabla; se interpretaron como vistas de trazabilidad siguiendo
   los ejemplos existentes y la petición anterior de auditoría.
8. Pedí un explorador interactivo propio, inspirado en `modelo-eer.html` de un
   compañero. Pedí usar “acrhify” y luego aclaré que se llama “archify”.
9. Finalmente pedí este archivo para trasladar el contexto a mi computadora.

## Organización del repositorio

`practica02` contiene scripts de usuarios remotos/roles, consultas, respaldos de
septiembre y `seeds/5000_productos.csv`. `practica03` contiene la ampliación del
modelo, CSV de categorías/productos/asociaciones y los archivos generados abajo.

El README raíz y el de práctica 2 solo documentaban las primeras prácticas;
no se actualizaron durante esta conversación.

## Qué se revisó realmente de la BD

El análisis original utilizó `practica03/backups/respaldo10_14.sql`, generado el
14 de octubre, NO el servidor local. Ese respaldo contiene:

| Tabla | Datos relevantes |
| --- | --- |
| `tb_users` | 7 registros; ID INT con signo; correo y nickname únicos. |
| `tb_products` | 5,008 registros; ID INT UNSIGNED; SKU único; precio DECIMAL(10,2); stock INT UNSIGNED. |
| `tbc_categories` | 100 registros; ID INT UNSIGNED; nombre único; `sup_id_category` sin FK declarada. |
| `tb_logs` | 5,015 registros; campos ID, table_name, operation, db_users, description, operation_date, operation_status. |

La bitácora usa `operation ENUM('Create','Read','Update','Delete')`; fecha automática
y `operation_status BIT(1)` predeterminado a 1. Había seis triggers AFTER: tres
en usuarios y tres en productos, que insertan en `tb_logs` usando `USER()`.

También había procedimientos `sp_soft_delete_product` y `sp_restore_product`
para cambiar el estado de productos, y vistas de trazabilidad de productos,
usuarios creados y categorías. La vista de productos original solo muestra altas.

IMPORTANTE: al preparar ESTE documento apareció un archivo adicional:
`practica03/backups/respaldo10_20.sql`. No se analizó su contenido. Puede ser una
fuente más reciente que la usada antes. El próximo chat debe revisarlo antes de
afirmar cuál es el esquema o estado actual. El explorador generado sigue usando
el respaldo del 14/10; no incorpora automáticamente ese archivo nuevo.

## Aclaración fundamental sobre los 5,000 productos

Yo confirmé que `practica02/seeds/5000_productos.csv` se dejó SOLO para que el
maestro viera el archivo en Git. NO es el catálogo realmente importado y NO hay
que cargarlo ni intentar hacer coincidir sus productos con la BD.

Se compararon sus SKU contra el respaldo del 14/10: coincidencias 0 de 5,000.
Que el respaldo tenga aproximadamente 5,000 productos no demuestra que provengan
de ese CSV. El origen del catálogo realmente importado no quedó establecido.

## Validaciones realizadas sobre los CSV de práctica 3

| CSV | Filas | Resultado de la revisión |
| --- | ---: | --- |
| `categorias_ecommerce_100.csv` | 100 | Los 100 ID y nombres coinciden con el respaldo. Sin ID/nombres duplicados ni padres ausentes en el CSV. |
| `tb_products_10000_nuevos.csv` | 10,000 | Sin SKU duplicados, sin coincidencias de SKU con el respaldo; nombres y SKU caben en las columnas. |
| `categorizacion_productos.csv` | 10,177 | Asociaciones por ID para 4,266 productos distintos; sin pares duplicados ni referencias ausentes respecto del respaldo y catálogo de categorías. |
| `tbd_products_categories_10000_por_sku.csv` | 31,536 | Todos los SKU existen en el CSV nuevo y todas las categorías en el catálogo; sin pares duplicados; los 10,000 productos tienen categoría. |

No se encontraron filas mal formadas en esos cuatro CSV. Los productos nuevos
no tienen precios ni existencias negativos; sus fechas tienen el formato esperado.
Hay 8,849 productos activos y 1,151 inactivos. El CSV no incluye ID: debe dejarse
que MySQL lo genere. Reimportarlo sin controlar duplicados chocaría con SKU único.

Si se agregan los 10,000 productos a los 5,008 del respaldo, serían 15,008; eso es
una expectativa condicionada a que el servidor tenga ese mismo estado.

Recomendaciones acordadas:

- No volver a insertar a ciegas las 100 categorías existentes; controlar duplicados.
- Interpretar `\N` como NULL en la categoría superior al importar.
- Importar primero productos y luego las asociaciones por SKU, resolviendo el ID
  real mediante JOIN, idealmente desde una tabla temporal de importación.
- Confirmar el origen de `categorizacion_productos.csv` antes de importarlo: que
  los ID existan NO demuestra que correspondan a los productos esperados. Si se
  generó contra el CSV de evidencia, podría clasificar mal sin fallar en SQL.
- Con triggers instalados, importar 10,000 productos generará 10,000 entradas de
  auditoría adicionales. El asistente NO realizó ninguna importación.

## Roles y permisos revisados

Los archivos `remote_users_privileges_creation.sql` de ambas prácticas eran iguales.
No reproducir aquí las contraseñas contenidas en esos scripts.

- `superadmin`: privilegios globales. No es necesario para cargas normales.
- `admin`: todos los privilegios sobre `db_test.*`; asignado a `marco.ramirez`.
- `seller`: SELECT, INSERT y UPDATE sobre `tb_products`; asignado a `olaf.garcia`
  y `eduardo.amaro`.
- `support`: SELECT, INSERT y UPDATE sobre `tb_users`; asignado a `yhostin.ramirez`.
- `buyer`, `common_user`, `user_not_registered`: creados sin privilegios propios
  explícitos en el script. Hay permisos CRUD directos sobre toda `db_test` para
  una cuenta con `common_user`, por lo que su alcance real es mayor que el rol.

Se recomendó `admin` para categorías y estructura, `seller` para productos y,
tras otorgar los permisos necesarios, para asociaciones. El vendedor requiere
SELECT sobre categorías y SELECT/INSERT sobre la tabla de relación; UPDATE solo
si va a gestionar sus estados. Estos permisos adicionales NO se otorgaron.

Los roles MySQL son de cuentas del servidor, no roles de registros de `tb_users`.

## Tablas solicitadas y diseño generado

Archivo: `practica03/scripts/create_ecommerce_tables.sql`.
Documento: `practica03/DISEÑO_ECOMMERCE.md`.

Las 13 tablas solicitadas son:

1. `tb_buyer_orders`
2. `tb_carts`
3. `tb_user_addresses`
4. `tbc_categories` (ya existía)
5. `tbc_payment_methods_types`
6. `tbc_order_items`
7. `tbc_carts_items`
8. `tbd_order_itemes`
9. `tbd_carts_items`
10. `tbd_products_categories`
11. `tbd_products_users_providers`
12. `tbd_user_payment_methods`
13. `tbd_users_wishilst_products`

Se respetaron los nombres, incluidos los errores `itemes` y `wishilst`.
Interpretación provisional explícita: `tbc_order_items` y `tbc_carts_items` son
catálogos de estados de detalles; sus equivalentes `tbd_` contienen las líneas.
El maestro no confirmó esa interpretación en esta conversación.

Reglas principales del diseño:

- Claves foráneas con tipos compatibles, cantidades positivas y montos no negativos.
- Pares únicos para evitar repetir asociaciones y productos en un carrito/pedido.
- Un carrito activo por usuario mediante columna generada e índice único.
- Solo carritos de usuarios registrados; máximo un pedido por carrito.
- Claves foráneas compuestas comprueban que dirección, carrito y medio guardado
  pertenezcan al comprador.
- El pedido guarda JSON de dirección histórica; el detalle guarda SKU, nombre y
  precio histórico. La aplicación debe construir esas copias.
- Medios de pago guardan token/referencia externa; no PAN completo ni CVV.
- Inventario y precio global por producto. Proveedor se vincula a `tb_users`;
  este diseño no es todavía un marketplace con ofertas por vendedor.
- No hay borrados en cascada. No se importan CSV ni se cambian permisos.
- `CREATE TABLE IF NOT EXISTS` no migra ni valida tablas ya existentes.

Yo confirmé que YA EJECUTÉ los scripts de creación de tablas en local. El
asistente no pudo verificar el resultado. No volver a crear ni alterar objetos
sin consultar primero el estado real o un respaldo actualizado.

Crítica constructiva: los prefijos son útiles, pero los catálogos de items son
ambiguos; convendría corregir los nombres y unificar estados ENUM/catálogos en una
migración futura. Faltan flujo transaccional de compra, control concurrente de
stock, validación de sumas cabecera/detalles, pagos/reembolsos, variantes, reglas
de transición e inmutabilidad de pedidos confirmados. El DDL no resuelve eso solo.

## Triggers generados posteriormente

- Instalación: `practica03/scripts/create_ecommerce_audit_triggers.sql`.
- Verificación: `practica03/querys/verificar_ecommerce_audit_triggers.sql`.

Son 39 triggers AFTER: INSERT → Create, UPDATE → Update, DELETE → Delete, para
cada una de las 13 tablas. UPDATE guarda antes y después; registra ID y USER().
Se omiten datos personales de direcciones y referencias de pago. No es un respaldo
completo de los registros. Usa el formato de descripción `... ID=..., datos=...`.

No sustituye los seis triggers originales ni crea triggers en `tb_logs`, para
evitar autorreferencia. Se esperan 45 en total si coincide con lo documentado.
Instalación única, sin DROP ni reemplazo: revisar existentes antes de ejecutar.
La auditoría se revierte con la transacción y no registra SELECT, TRUNCATE, fallos
ni operaciones anteriores a instalar triggers.

Se revisaron estáticamente nombres, cobertura y campos; NO se probaron en MySQL.
Yo NO confirmé explícitamente haber ejecutado estos triggers.

## Vistas generadas

- Instalación: `practica03/scripts/create_ecommerce_audit_views.sql`.
- Verificación: `practica03/querys/verificar_ecommerce_audit_views.sql`.

Son 13 vistas de trazabilidad llamadas `vw_trazabilidad_` + nombre completo de
tabla. Muestran log_id, tabla, record_id, operación, cuenta, username, roles,
descripción, fecha y estado. No unen con tablas de negocio, por lo que conservan
visible el historial de registros eliminados.

Los roles se consultan en `mysql.role_edges`: son roles directos actuales por
nombre de cuenta, no roles históricos, heredados ni necesariamente activos;
pueden agrupar cuentas homónimas de distintos hosts. Usan SQL SECURITY INVOKER,
por lo que requieren permisos sobre `tb_logs` y `mysql.role_edges` al consultar.
No se otorgaron esos permisos. No reemplazan las vistas antiguas.

La generación fue revisada estáticamente. NO se ejecutaron en servidor y yo NO
confirmé haberlas instalado. El verificador debe mostrar 13 resultados OK.

## Explorador interactivo

El archivo `practica03/modelo-eer.html` pertenece a un compañero. El asistente leyó
su código como referencia; no lo modificó. Es un explorador con datos incorporados
desde un dump, no una conexión en vivo.

Mi versión nueva:

- `practica03/explorador-eer.html`: abrir directamente en navegador, sin servidor
  ni dependencias externas. Nombre visual: “Atlas de datos”, matrícula 240687.
- `practica03/EXPLORADOR.md`: uso, procedencia y límites.
- `practica03/scripts/eer_explorer_template.html`: plantilla editable.
- `practica03/scripts/generate_eer_explorer.py`: genera el HTML desde respaldo y
  scripts. Ejecutar desde la raíz: `python practica03/scripts/generate_eer_explorer.py`.

Incluye 16 tablas, 137 columnas, 20 FK y 45 triggers documentados. Combina cuatro
tablas del respaldo del 14/10 con doce adicionales del script; para tablas que ya
existen prevalece el respaldo. No incluye datos personales ni contraseñas.

Funciones: buscar tabla/columna, filtrar por función, zoom, desplazar fondo,
arrastrar tablas, navegar relaciones, consultar DDL y auditoría, copiar SQL y
exportar SVG de lo visible. Ctrl+K enfoca búsqueda y Escape cierra detalles.
No persiste posiciones entre sesiones. Las flechas apuntan a la tabla referenciada;
no es una notación completa de cardinalidades EER.

Los conteos son del respaldo; `s/d` indica falta de información de ejecución,
NO que la tabla esté vacía. La jerarquía de categorías no se dibuja como FK porque
el respaldo no la declara. El explorador no comprueba instalación de los scripts.

Se validó sintaxis JavaScript con `node --check`, referencias DOM, conteos y FK
contra columnas del modelo. NO hubo prueba visual/interactiva en navegador;
Playwright no estaba instalado. Si algo falla visualmente, revisar y corregir.

### Situación de Archify

Pedí explícitamente Archify. No se encontró entre las herramientas conectadas
ni en la búsqueda del catálogo de plugins. No se instaló ni se usó Archify.
La versión entregada es una implementación local alternativa, no generada con
ese servicio. No afirmar que sí se utilizó. Sigue pendiente identificar el enlace
o integración exacta si quiero continuar con esa herramienta. Se consultaron las
guías disponibles de gestión de plugins y Sites; no se creó ni publicó un Site.

## Estado de Git y traslado a otra computadora

No se hizo commit, push ni publicación durante esta conversación. Al preparar
este documento `git status` mostraba `respaldo10_14.sql` modificado y numerosos
archivos sin seguimiento: scripts y documentación generados, explorador, CSV,
HTML del compañero y `backups/respaldo10_20.sql`. La modificación del respaldo
preexistía al trabajo del asistente; no se sobrescribió.

IMPORTANTE: un clone/pull en la PC personal NO traerá archivos no confirmados y
no subidos. Debo copiar el proyecto completo o seleccionar, revisar, confirmar y
subir los archivos que quiera trasladar. Este documento por sí solo no contiene
todo el código. No se ha autorizado ni realizado un push automático.

La BD local de esta computadora tampoco se traslada con Git: para conservar su
estado necesito un respaldo actualizado y restaurarlo en mi MySQL personal.
Revisar el nuevo respaldo del 20/10 antes de elegir cuál usar.

## Orden recomendado para retomar

1. Ubicar el repositorio y leer este contexto, la documentación y los scripts.
2. Revisar `respaldo10_20.sql`; contrastar con el del 14/10 y, si hay acceso,
   consultar SHOW CREATE TABLE, SHOW TRIGGERS y las vistas del servidor actual.
3. Establecer qué tablas, triggers, vistas y cargas están realmente instaladas.
   No confundir scripts generados con operaciones ejecutadas.
4. Respaldar antes de migrar. Evitar repetir creación de triggers/vistas o cargas.
5. Resolver cualquier error de los verificadores en una instancia de prueba/local.
6. Validar origen de las asociaciones por ID y preparar cargas seguras por SKU.
7. Actualizar el explorador para usar el respaldo correcto y probarlo en navegador.
8. Si se mantiene el requisito Archify, identificar su integración sin atribuir
   falsamente la implementación local a esa herramienta.

No quedan credenciales de conexión registradas en este contexto. Los scripts
originales sí contienen contraseñas en texto claro; no imprimirlas ni copiarlas
a documentos adicionales.
