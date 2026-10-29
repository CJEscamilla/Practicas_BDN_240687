-- Cobertura de las 25 tablas de negocio del respaldo10_28.sql.
-- Ejecutar antes y despues de scripts/create_missing_audit_views_10_28.sql.
-- Solo lee metadatos. Se esperan 25 vistas canonicas con estado EXISTE.
-- Las tres vistas antiguas con nombres alternativos se conservan.
USE db_test;
SELECT e.table_name, e.view_name,
       IF(t.TABLE_NAME IS NULL, 'FALTA TABLA', 'EXISTE') AS tabla,
       CASE WHEN v.TABLE_NAME IS NOT NULL THEN 'EXISTE'
            WHEN occupied.TABLE_NAME IS NOT NULL THEN 'NOMBRE OCUPADO POR TABLA'
            ELSE 'FALTA' END AS vista,
       v.SECURITY_TYPE,
       (SELECT COUNT(*) FROM information_schema.TRIGGERS tr
        WHERE tr.TRIGGER_SCHEMA = DATABASE()
          AND tr.EVENT_OBJECT_TABLE = e.table_name
          AND tr.ACTION_TIMING = 'AFTER') AS triggers_after
FROM (
    SELECT 'tb_buyer_orders' AS table_name, 'vw_trazabilidad_tb_buyer_orders' AS view_name
    UNION ALL SELECT 'tb_carts' AS table_name, 'vw_trazabilidad_tb_carts' AS view_name
    UNION ALL SELECT 'tb_order_cancellations' AS table_name, 'vw_trazabilidad_tb_order_cancellations' AS view_name
    UNION ALL SELECT 'tb_payment_methods' AS table_name, 'vw_trazabilidad_tb_payment_methods' AS view_name
    UNION ALL SELECT 'tb_payment_transaction' AS table_name, 'vw_trazabilidad_tb_payment_transaction' AS view_name
    UNION ALL SELECT 'tb_payments' AS table_name, 'vw_trazabilidad_tb_payments' AS view_name
    UNION ALL SELECT 'tb_people' AS table_name, 'vw_trazabilidad_tb_people' AS view_name
    UNION ALL SELECT 'tb_products' AS table_name, 'vw_trazabilidad_tb_products' AS view_name
    UNION ALL SELECT 'tb_refunds' AS table_name, 'vw_trazabilidad_tb_refunds' AS view_name
    UNION ALL SELECT 'tb_returns' AS table_name, 'vw_trazabilidad_tb_returns' AS view_name
    UNION ALL SELECT 'tb_shipments' AS table_name, 'vw_trazabilidad_tb_shipments' AS view_name
    UNION ALL SELECT 'tb_user_addresses' AS table_name, 'vw_trazabilidad_tb_user_addresses' AS view_name
    UNION ALL SELECT 'tb_users' AS table_name, 'vw_trazabilidad_tb_users' AS view_name
    UNION ALL SELECT 'tbc_carts_items' AS table_name, 'vw_trazabilidad_tbc_carts_items' AS view_name
    UNION ALL SELECT 'tbc_categories' AS table_name, 'vw_trazabilidad_tbc_categories' AS view_name
    UNION ALL SELECT 'tbc_order_items' AS table_name, 'vw_trazabilidad_tbc_order_items' AS view_name
    UNION ALL SELECT 'tbc_payment_methods_types' AS table_name, 'vw_trazabilidad_tbc_payment_methods_types' AS view_name
    UNION ALL SELECT 'tbd_cancellation_items' AS table_name, 'vw_trazabilidad_tbd_cancellation_items' AS view_name
    UNION ALL SELECT 'tbd_carts_items' AS table_name, 'vw_trazabilidad_tbd_carts_items' AS view_name
    UNION ALL SELECT 'tbd_order_itemes' AS table_name, 'vw_trazabilidad_tbd_order_itemes' AS view_name
    UNION ALL SELECT 'tbd_products_categories' AS table_name, 'vw_trazabilidad_tbd_products_categories' AS view_name
    UNION ALL SELECT 'tbd_products_users_providers' AS table_name, 'vw_trazabilidad_tbd_products_users_providers' AS view_name
    UNION ALL SELECT 'tbd_return_items' AS table_name, 'vw_trazabilidad_tbd_return_items' AS view_name
    UNION ALL SELECT 'tbd_user_payment_methods' AS table_name, 'vw_trazabilidad_tbd_user_payment_methods' AS view_name
    UNION ALL SELECT 'tbd_users_wishilst_products' AS table_name, 'vw_trazabilidad_tbd_users_wishilst_products' AS view_name
) e
LEFT JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = DATABASE() AND t.TABLE_NAME = e.table_name
 AND t.TABLE_TYPE = 'BASE TABLE'
LEFT JOIN information_schema.VIEWS v
  ON v.TABLE_SCHEMA = DATABASE() AND v.TABLE_NAME = e.view_name
LEFT JOIN information_schema.TABLES occupied
  ON occupied.TABLE_SCHEMA = DATABASE() AND occupied.TABLE_NAME = e.view_name
ORDER BY e.table_name;
-- Existencia no demuestra definicion correcta ni que haya eventos auditados.
-- Revisar SHOW CREATE VIEW si se conserva un objeto preexistente.
