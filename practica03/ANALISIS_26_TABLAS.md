# Análisis y adaptación del archivo de 26 tablas

Revisión: 27 de octubre de 2026. Referencia comprobada: el esquema de
`backups/respaldo10_20.sql`, no una conexión al servidor actual.

## Resultado

`scripts/Crear_26_tablas_db_test.sql` se conserva como referencia original.
Declara proceder de `Respaldo_27102026.sql`, pero ese respaldo no está entre los
respaldos disponibles. Su esquema difiere del que tiene este proyecto.

La adaptación está en `scripts/crear_ampliacion_26_tablas_adaptada.sql`.
Conserva las 16 tablas del respaldo del 20/10 y crea 10 tablas nuevas:
`tb_people`, `tb_payment_methods`, `tb_payments`, `tb_order_cancellations`,
`tb_returns`, `tb_shipments`, `tb_refunds`, `tb_payment_transaction`,
`tbd_cancellation_items` y `tbd_return_items`. El resultado previsto son 26 tablas,
pero no son exactamente las mismas 26 del archivo original.

## Conflictos del original

- Intenta crear de nuevo tablas existentes, sin ser una migración.
- Usa `tb_users.ID INT UNSIGNED`; nuestro respaldo usa `INT` con signo.
  Las nuevas referencias a usuarios se adaptaron a `INT`.
- Redefine direcciones y medios guardados con ID BIGINT; los existentes usan
  INT UNSIGNED. Se ajustó la referencia de envíos a las direcciones existentes.
- Cambia carritos de ENUM a BIT y permite un solo carrito por usuario para toda
  su vida, mientras nuestro modelo permite varios históricos y uno activo.
- Usa `tb_orders`, `tbd_buyer_orders`, `tbd_order_items`, `tbd_cart_items` y
  `tbd_users_wishlist_products`. Aquí ya existen `tb_buyer_orders`,
  `tbd_order_itemes`, `tbd_carts_items` y `tbd_users_wishilst_products`.
  Crear ambos conjuntos duplicaría flujos de negocio.
- El subpedido del vendedor `tbd_buyer_orders` no referencia el pedido global.
  Sus detalles y envíos no podrían asociarse al pedido global mediante esas FK.
- En los detalles originales, dos FK separadas a proveedor y producto no
  garantizan que exista la pareja proveedor/producto.
- Desactiva comprobaciones de FK para crear las tablas fuera de orden.
  La adaptación mantiene las comprobaciones activas y ordena las dependencias.
- Copia contadores AUTO_INCREMENT del respaldo de origen; se retiraron de las
  tablas nuevas porque no se están importando sus registros.

## Decisiones de adaptación

Pagos, envíos, devoluciones y cancelaciones referencian `tb_buyer_orders`.
Los artículos devueltos o cancelados referencian `tbd_order_itemes`.
Se conserva el modelo actual de tienda con inventario global, sin agregar
subpedidos de vendedor. Por ello se elimina el alcance `SellerOrder` y la
columna de subpedido de las cancelaciones; permanecen `WholeOrder` e `Items`.
En envíos y devoluciones la columna del pedido se llama `order_ID`.

`tb_payment_methods` conserva el catálogo de métodos aceptados del original.
Es independiente de `tbc_payment_methods_types`, que clasifica los medios
guardados por usuario. La aplicación debe definir su correspondencia; el script
no crea datos de catálogo ni vincula un pago con un token guardado.

`tb_people` conserva el diseño de origen, que permite más de una persona por
usuario. Si el requisito es un perfil por cuenta, habrá que acordar una
restricción UNIQUE sobre `user_ID`.

## Alcance y comprobaciones

Se comprobaron estáticamente las 16 tablas previas y las 10 nuevas, las 19 FK
nuevas, la compatibilidad de sus tipos, el orden de creación y la ausencia de
colisiones entre nombres de restricciones. No se probó la ejecución en MySQL.
No se modificaron tablas, datos, triggers, vistas ni permisos del servidor.

Antes de ejecutar, contrastar el esquema real con el respaldo del 20/10 y
comprobar que las diez tablas nuevas aún no existen. Obtener un respaldo actual.
El script se ejecuta una sola vez sobre `db_test`, sin ignorar errores.
No usa IF NOT EXISTS para evitar ocultar tablas nuevas con estructuras distintas.
El DDL hace COMMIT implícito: una falla puede dejar una instalación parcial.

Las FK no validan que el detalle de una devolución o cancelación corresponda al
mismo pedido de su cabecera, ni que un reembolso corresponda al pedido del pago.
Tampoco comprueban propiedad de la dirección de envío, moneda, acumulados de
reembolsos, cantidades ya devueltas/canceladas, transiciones o stock. Esas reglas
requieren un flujo transaccional antes de operar compras reales. Los importes de
pagos conservan DECIMAL(10,2), menor que DECIMAL(14,2) del pedido; ampliar su rango
requiere definir los límites de negocio. No se incluyen triggers ni vistas de
auditoría para estas diez tablas nuevas.
