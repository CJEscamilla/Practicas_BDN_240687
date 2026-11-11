# Revisión de vistas de trazabilidad

27/10/2026. Se revisaron los archivos y `backups/respaldo10_20.sql`.
No hay conexión autenticada al servidor: existencia en respaldo no demuestra
instalación actual. La lista solicitada tiene 25 conceptos únicos; órdenes se
mencionó dos veces y corresponde a `tb_buyer_orders` en el diseño adaptado.

## Resultado de la comparación

De las 25 vistas solicitadas, 12 están en el respaldo y 13 se agregaron en
`scripts/create_missing_audit_views.sql`. Se conserva el script anterior de
13 vistas sin cambios. El complemento comprueba cada nombre en el servidor
y conserva cualquier objeto existente en lugar de sustituirlo.

| Concepto | Vista | Estado en respaldo |
| --- | --- | --- |
| Address components | vw_trazabilidad_tbd_address_components | Nueva |
| Cancelaciones | vw_trazabilidad_tb_order_cancellations | Nueva |
| Órdenes | vw_trazabilidad_tb_buyer_orders | Existe |
| Carritos | vw_trazabilidad_tb_carts | Existe |
| Categorías de productos | vw_trazabilidad_tbd_products_categories | Existe |
| Categorías | vw_trazabilidad_tbc_categories | Existe |
| Devoluciones | vw_trazabilidad_tb_returns | Nueva |
| Direcciones | vw_trazabilidad_tb_user_addresses | Existe |
| Usuarios | vw_trazabilidad_tb_users | Nueva |
| Items cancelaciones | vw_trazabilidad_tbd_cancellation_items | Nueva |
| Envíos | vw_trazabilidad_tb_shipments | Nueva |
| Items carritos | vw_trazabilidad_tbd_carts_items | Existe |
| Items devoluciones | vw_trazabilidad_tbd_return_items | Nueva |
| Items orders | vw_trazabilidad_tbd_order_itemes | Existe |
| Métodos de pago | vw_trazabilidad_tb_payment_methods | Nueva |
| Métodos pago usuario | vw_trazabilidad_tbd_user_payment_methods | Existe |
| Pagos | vw_trazabilidad_tb_payments | Nueva |
| People | vw_trazabilidad_tb_people | Nueva |
| Productos | vw_trazabilidad_tb_products | Nueva, historial completo |
| Productos proveedores | vw_trazabilidad_tbd_products_users_providers | Existe |
| Reembolsos | vw_trazabilidad_tb_refunds | Nueva |
| Tipos métodos de pago | vw_trazabilidad_tbc_payment_methods_types | Existe |
| Transacciones pago | vw_trazabilidad_tb_payment_transaction | Nueva |
| Usuarios creados | vw_trazabilidad_usuarios_creados | Existe |
| Wishlists usuarios | vw_trazabilidad_tbd_users_wishilst_products | Existe |

La antigua `vw_trazabilidad_productos` solo muestra Create. Se conserva y se
agrega `vw_trazabilidad_tb_products` sin limitar operaciones. También se conserva
`vw_trazabilidad_usuarios_creados`, cuyo JOIN con usuarios actuales puede omitir
usuarios eliminados o modificados; la nueva vista de usuarios lee solo la bitácora.

## Uso y límites

Ejecutar `querys/verificar_vistas_trazabilidad_completas.sql` antes y después del
complemento para revisar el servidor real. Si faltan vistas del grupo previo,
revisar su instalación individual: el complemento solo agrega las 13 nuevas.
No volver a ejecutar a ciegas el script previo si algunas vistas ya existen.

Las nuevas vistas leen `tb_logs`, conservan eventos de registros eliminados y
muestran operación, cuenta, descripción, fecha y estado. `record_id` solo se
extrae cuando la descripción contiene el formato `ID=numero,`; puede ser NULL
en logs antiguos o tablas con otra clave. La descripción original permanece.
Los roles son directos actuales agrupados por nombre, no históricos ni efectivos.
SQL SECURITY INVOKER requiere SELECT sobre `tb_logs` y `mysql.role_edges`.

`tbd_address_components` no se incluyó en la ampliación adaptada porque las
direcciones existentes ya guardan sus componentes como columnas. Su vista puede
crearse al depender solo de `tb_logs`, pero no implica que exista la tabla.
Tampoco se instalaron triggers para las diez tablas nuevas. Las vistas no generan
auditoría ni reconstruyen eventos pasados. El verificador muestra existencia de
tablas y cantidad de triggers AFTER; ese conteo no demuestra su contenido.

Se comprobaron estáticamente los 13 nombres nuevos, filtros, bloques de SQL
dinámico y cobertura de los 25 conceptos frente al respaldo. Falta ejecutar y
validar en MySQL; no se realizaron cambios en el servidor.
