-- 25 vistas solicitadas unicas (ordenes estaba repetido).
-- Solo consulta metadatos. No requiere leer mysql.role_edges.
USE db_test;
SELECT e.table_name, e.view_name,
       IF(v.TABLE_NAME IS NULL, 'FALTA', 'EXISTE') AS vista,
       IF(t.TABLE_NAME IS NULL, 'FALTA TABLA', 'EXISTE') AS tabla,
       (SELECT COUNT(*) FROM information_schema.TRIGGERS tr
        WHERE tr.TRIGGER_SCHEMA = DATABASE() AND tr.EVENT_OBJECT_TABLE = e.table_name
          AND tr.ACTION_TIMING = 'AFTER') AS triggers_after,
       v.SECURITY_TYPE
FROM (
    SELECT 'tbd_address_components' AS table_name, 'vw_trazabilidad_tbd_address_components' AS view_name
    UNION ALL SELECT 'tb_order_cancellations' AS table_name, 'vw_trazabilidad_tb_order_cancellations' AS view_name
    UNION ALL SELECT 'tb_buyer_orders' AS table_name, 'vw_trazabilidad_tb_buyer_orders' AS view_name
    UNION ALL SELECT 'tb_carts' AS table_name, 'vw_trazabilidad_tb_carts' AS view_name
    UNION ALL SELECT 'tbd_products_categories' AS table_name, 'vw_trazabilidad_tbd_products_categories' AS view_name
    UNION ALL SELECT 'tbc_categories' AS table_name, 'vw_trazabilidad_tbc_categories' AS view_name
    UNION ALL SELECT 'tb_returns' AS table_name, 'vw_trazabilidad_tb_returns' AS view_name
    UNION ALL SELECT 'tb_user_addresses' AS table_name, 'vw_trazabilidad_tb_user_addresses' AS view_name
    UNION ALL SELECT 'tb_users' AS table_name, 'vw_trazabilidad_tb_users' AS view_name
    UNION ALL SELECT 'tbd_cancellation_items' AS table_name, 'vw_trazabilidad_tbd_cancellation_items' AS view_name
    UNION ALL SELECT 'tb_shipments' AS table_name, 'vw_trazabilidad_tb_shipments' AS view_name
    UNION ALL SELECT 'tbd_carts_items' AS table_name, 'vw_trazabilidad_tbd_carts_items' AS view_name
    UNION ALL SELECT 'tbd_return_items' AS table_name, 'vw_trazabilidad_tbd_return_items' AS view_name
    UNION ALL SELECT 'tbd_order_itemes' AS table_name, 'vw_trazabilidad_tbd_order_itemes' AS view_name
    UNION ALL SELECT 'tb_payment_methods' AS table_name, 'vw_trazabilidad_tb_payment_methods' AS view_name
    UNION ALL SELECT 'tbd_user_payment_methods' AS table_name, 'vw_trazabilidad_tbd_user_payment_methods' AS view_name
    UNION ALL SELECT 'tb_payments' AS table_name, 'vw_trazabilidad_tb_payments' AS view_name
    UNION ALL SELECT 'tb_people' AS table_name, 'vw_trazabilidad_tb_people' AS view_name
    UNION ALL SELECT 'tb_products' AS table_name, 'vw_trazabilidad_tb_products' AS view_name
    UNION ALL SELECT 'tbd_products_users_providers' AS table_name, 'vw_trazabilidad_tbd_products_users_providers' AS view_name
    UNION ALL SELECT 'tb_refunds' AS table_name, 'vw_trazabilidad_tb_refunds' AS view_name
    UNION ALL SELECT 'tbc_payment_methods_types' AS table_name, 'vw_trazabilidad_tbc_payment_methods_types' AS view_name
    UNION ALL SELECT 'tb_payment_transaction' AS table_name, 'vw_trazabilidad_tb_payment_transaction' AS view_name
    UNION ALL SELECT 'tbd_users_wishilst_products' AS table_name, 'vw_trazabilidad_tbd_users_wishilst_products' AS view_name
    UNION ALL SELECT 'tb_users' AS table_name, 'vw_trazabilidad_usuarios_creados' AS view_name
) e
LEFT JOIN information_schema.VIEWS v
  ON v.TABLE_SCHEMA = DATABASE() AND v.TABLE_NAME = e.view_name
LEFT JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = DATABASE() AND t.TABLE_NAME = e.table_name
 AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY e.view_name;
-- La existencia no prueba la definicion ni que los triggers escriban en tb_logs.
-- Consultar SHOW CREATE VIEW y SHOW CREATE TRIGGER si hay objetos preexistentes.
