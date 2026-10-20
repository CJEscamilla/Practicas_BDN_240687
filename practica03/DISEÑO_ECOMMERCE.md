# Ampliación del esquema de comercio electrónico

El archivo `scripts/create_ecommerce_tables.sql` define las 13 tablas solicitadas,
incluida `tbc_categories`, que ya existe y se conserva. Se basa en el respaldo
`backups/respaldo10_14.sql` de MySQL 8.0.36. No se ha ejecutado contra un servidor.

## Interpretaciones que deben revisarse con el docente

- `tb_`: entidades; `tbc_`: catálogos; `tbd_`: detalles y relaciones.
- `tbc_order_items` y `tbc_carts_items` se interpretan provisionalmente como
  catálogos de estados de renglones. Los productos, cantidades y precios del pedido
  pertenecen a `tbd_order_itemes`; los productos y cantidades del carrito a
  `tbd_carts_items`. Si el docente da otra función a estos catálogos, ajustar antes
  de ejecutar. Los nombres por sí solos no permiten deducir esa intención.
- Se mantienen los nombres solicitados, incluidos `itemes` y `wishilst`.
- Es una tienda con inventario y precio global por producto. Un proveedor es un
  usuario de `tb_users`; esta relación no implica ventas de múltiples vendedores.
- Solo se permiten carritos de usuarios registrados y uno activo por usuario.
- Se permite un pedido por carrito, una línea por producto y múltiples medios
  de pago guardados por usuario. El pedido referencia como máximo uno de ellos;
  puede quedar sin medio guardado para pagos externos o en efectivo.

## Relaciones y reglas implementadas

- Usuarios → direcciones, medios de pago, carritos, pedidos y favoritos.
- Productos ↔ categorías; productos ↔ usuarios proveedores.
- Pedidos → detalles; carritos → detalles; detalles → producto y estado.
- Las claves foráneas de pedido también comprueban que dirección, carrito y medio
  de pago pertenezcan al comprador. Los tipos INT con/sin signo coinciden con las
  tablas existentes.
- Cantidades positivas, importes no negativos y pares de relación únicos.
- El precio y nombre/SKU de una compra se guardan como copia histórica. También
  se exige una copia JSON de la dirección de envío; la aplicación debe construirla.
- No hay eliminaciones en cascada: las referencias protegen el historial.
- El total del pedido se calcula a partir de su cabecera. `subtotal` representa
  la suma de cantidad × precio antes de descuentos e impuestos; `discount_total`
  y `tax_total` agregan los de sus detalles. El envío se suma solo en cabecera.

## Responsabilidades pendientes

El script crea estructura, no implementa el proceso de compra completo:

1. Poblar los dos catálogos de estados y el catálogo de tipos de pago. Por ejemplo,
   estados de detalle de pedido: pending, fulfilled, cancelled; de carrito: active,
   saved, unavailable. Seleccionar sus ID por código, sin asumir valores numéricos.
2. Importar productos y resolver asociaciones CSV por SKU antes de guardar los ID.
3. Crear una transacción de compra que bloquee/verifique inventario, copie precios
   y dirección, calcule importes, cree cabecera y detalles, descuente existencias y
   convierta el carrito. El DDL no comprueba stock ni suma detalles entre tablas.
4. Impedir cambios a las copias históricas una vez confirmado el pedido y validar
   transiciones de estados. Una FK no comprueba que un registro siga activo.
5. Instalar `scripts/create_ecommerce_audit_triggers.sql`: agrega 39 triggers,
   tres por tabla. Revisar con `querys/verificar_ecommerce_audit_triggers.sql`.
   No cambia los seis triggers existentes ni los permisos.
6. Definir el rol de proveedor dentro de la plataforma. Los roles MySQL actuales
   no clasifican automáticamente a los registros de `tb_users`.
7. Añadir transacciones de pago y reembolsos cuando se integre una pasarela. Un medio
   guardado no equivale a un pago realizado. Guardar tokens/referencias, nunca CVV
   ni el número completo de tarjeta.

## Crítica constructiva y mejoras futuras

Separar entidades, catálogos y relaciones es una buena base para normalizar y
evitar duplicar productos por categoría. El prefijo no sustituye una definición
clara de cada tabla: `tbc_order_items` y `tbc_carts_items` son ambiguos. Si realmente
son estados, nombres como `tbc_order_item_statuses` los explicarían mejor.

Los errores ortográficos elevan el costo de escribir consultas y mantener código;
sería conveniente acordar `tbd_order_items` y `tbd_users_wishlist_products` antes
de desarrollar aplicaciones, aunque aquí se conserva la nomenclatura indicada.

El modelo mezcla catálogos para estados de detalles y ENUM para estados de
cabeceras. Funciona para esta práctica, pero conviene unificar el criterio si los
estados van a cambiar con frecuencia. También se mantienen BIT y otros tipos de
estado existentes; estandarizarlos requeriría una migración separada.

`tbc_categories.sup_id_category` todavía no tiene FK. Agregarla exige primero
validar referencias y ciclos existentes; una FK por sí sola no impide ciclos.

Una tienda multivendedor requiere ofertas por vendedor (precio/stock propios),
vendedor histórico por detalle y posiblemente envíos separados. La relación de
proveedores propuesta no resuelve ese escenario. Tampoco contempla variantes de
producto, reservas de stock, compras de invitados ni división de pagos.

## Ejecución y límites de validación

Revisar `SHOW CREATE TABLE` en el servidor y obtener un respaldo actualizado antes
de ejecutar con `admin`. Cargar el script en la conexión autenticada de MySQL
Workbench o MySQL Shell, seleccionando `db_test`.

`CREATE TABLE IF NOT EXISTS` evita recrear tablas, pero NO verifica ni corrige su
estructura. Si alguna ya existe con columnas diferentes, detenerse y preparar
una migración específica. No ejecutar con opciones que ignoren errores.

MySQL hace COMMIT implícito para este DDL: una falla puede dejar parte de las tablas
creadas. No se desactivan las claves foráneas. Se revisaron estáticamente los nombres,
el orden de dependencias y los tipos; queda pendiente la ejecución en MySQL 8.0.36.

## Instalacion de auditoria

Ejecutar el script de triggers una sola vez, despues de crear las tablas.
INSERT registra Create, UPDATE registra Update (antes y despues) y DELETE
registra Delete. USER() identifica la conexion MySQL. Se omiten referencias de
pago y datos personales de direcciones; el log no es un respaldo completo.
No sustituye triggers existentes. Revisarlos antes para evitar duplicados.
No crear triggers que escriban en tb_logs sobre la propia tb_logs.
Los logs se revierten junto con su transaccion y no registran operaciones
previas a la instalacion, SELECT ni TRUNCATE. Los nuevos triggers se revisaron
estaticamente; falta probarlos en MySQL. Se esperan 39 nuevos y 6 existentes,
45 en total si la BD coincide con el respaldo y no hay otros triggers.

## Vistas de trazabilidad

`scripts/create_ecommerce_audit_views.sql` crea 13 vistas, una por tabla,
con el nombre `vw_trazabilidad_` seguido del nombre completo de tabla.
No sustituye las vistas anteriores. Ejecutar una sola vez con CREATE VIEW,
SELECT sobre tb_logs y mysql.role_edges; comprobar con
`querys/verificar_ecommerce_audit_views.sql`.

Incluyen las tres operaciones, ID del registro, cuenta MySQL, nombre de usuario,
roles directos actuales agrupados por nombre, descripcion, fecha y estado del log.
No unen con las tablas de negocio: conservan visibles operaciones de registros
eliminados. No son vistas del catalogo actual, sino del historial de auditoria.
Los roles no son historicos ni efectivos y pueden agrupar cuentas de diferentes
hosts con el mismo nombre. Se usa SQL SECURITY INVOKER: quien consulte necesita
permisos de lectura de los objetos subyacentes, incluido mysql.role_edges.
No otorgar acceso a tablas del sistema sin evaluar el alcance; si el usuario no
lo tiene, el administrador puede consultar estas vistas.

El ID se extrae del prefijo anterior al JSON generado por los triggers. Las vistas
pueden estar vacias hasta que haya operaciones posteriores a instalar triggers.
No reconstruyen cargas anteriores y la auditoria no sobrevive a un ROLLBACK.
Se verificaron estaticamente los 13 nombres y filtros; falta probar en MySQL.
